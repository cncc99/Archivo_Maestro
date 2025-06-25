import tkinter as tk
from tkinter import ttk, filedialog, messagebox, Listbox, Scrollbar, StringVar, BooleanVar
from tkinterdnd2 import TkinterDnD, DND_FILES
import os
import shutil
import logging
from pathlib import Path
import mimetypes  # Reemplazo para detección de tipo MIME
import threading
import time
from datetime import datetime

# Configuración de logging
logging.basicConfig(
    filename='organizador.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Inicializar mimetypes
mimetypes.init()

class FileOrganizerApp(TkinterDnD.Tk):
    def __init__(self):
        super().__init__()
        self.title("Organizador Avanzado de Archivos")
        self.geometry("800x700")
        self.configure(bg="#f0f0f0")
        
        # Variables
        self.target_path = StringVar(value="")
        self.dragged_files = []
        self.dry_run = BooleanVar(value=False)
        self.progress = StringVar(value="Listo")
        self.running = False
        
        # Crear widgets
        self.create_widgets()
    
    def create_widgets(self):
        style = ttk.Style()
        style.theme_use("vista")
        style.configure("TFrame", background="#ffffff")
        style.configure("TLabel", background="#ffffff", font=("Segoe UI", 9))
        style.configure("TButton", font=("Segoe UI", 9))
        style.configure("Title.TLabel", font=("Segoe UI", 14, "bold"))
        style.configure("Section.TLabelframe.Label", font=("Segoe UI", 10, "bold"))
        style.configure("Accent.TButton", background="#0E0F0E", foreground="white")
        style.map("Accent.TButton", background=[("active", "#000000")])
        
        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        ttk.Label(main_frame, text="Organizador de Archivos", style="Title.TLabel").pack(pady=(0, 15))
        
        # Sección de ubicación de destino
        location_frame = ttk.LabelFrame(main_frame, text="Ubicación de Destino")
        location_frame.pack(fill="x", pady=10)
        
        ttk.Label(location_frame, text="Carpeta para organización:").grid(row=0, column=0, padx=5, pady=5, sticky="w")
        
        path_entry = ttk.Entry(location_frame, textvariable=self.target_path, width=50)
        path_entry.grid(row=0, column=1, padx=5, pady=5, sticky="we")
        
        ttk.Button(
            location_frame, 
            text="Seleccionar...", 
            command=self.browse_folder
        ).grid(row=0, column=2, padx=5, pady=5)
        
        # Modo de prueba
        ttk.Checkbutton(
            location_frame,
            text="Modo prueba (no mueve archivos)",
            variable=self.dry_run
        ).grid(row=1, column=0, columnspan=3, padx=5, pady=5, sticky="w")
        
        # Área de arrastre
        drop_frame = ttk.LabelFrame(main_frame, text="Arrastra archivos aquí")
        drop_frame.pack(fill="both", expand=True, pady=10)
        
        list_frame = ttk.Frame(drop_frame)
        list_frame.pack(fill="both", expand=True, padx=5, pady=5)
        
        scrollbar = Scrollbar(list_frame)
        scrollbar.pack(side="right", fill="y")
        
        self.file_listbox = Listbox(
            list_frame,
            selectmode=tk.EXTENDED,
            height=12,
            bg="white",
            relief="sunken",
            yscrollcommand=scrollbar.set
        )
        self.file_listbox.pack(fill="both", expand=True)
        scrollbar.config(command=self.file_listbox.yview)
        
        self.file_listbox.drop_target_register(DND_FILES)
        self.file_listbox.dnd_bind('<<Drop>>', self.on_drop)
        
        # Botones de gestión de archivos
        file_btn_frame = ttk.Frame(main_frame)
        file_btn_frame.pack(fill="x", pady=5)
        
        ttk.Button(
            file_btn_frame, 
            text="Agregar archivos...", 
            command=self.add_files
        ).pack(side="left", padx=2)
        
        ttk.Button(
            file_btn_frame, 
            text="Eliminar seleccionados", 
            command=self.remove_selected_files
        ).pack(side="left", padx=2)
        
        ttk.Button(
            file_btn_frame, 
            text="Limpiar todos", 
            command=self.clear_all_files
        ).pack(side="left", padx=2)
        
        # Botón de organización
        self.organize_btn = ttk.Button(
            main_frame, 
            text="Organizar Archivos", 
            style="Accent.TButton",
            command=self.start_organization_thread
        )
        self.organize_btn.pack(pady=15)
        
        # Barra de progreso
        self.progress_frame = ttk.Frame(main_frame)
        self.progress_frame.pack(fill="x", pady=5)
        
        self.progress_label = ttk.Label(self.progress_frame, textvariable=self.progress)
        self.progress_label.pack(fill="x", pady=5)
        
        # Barra de estado
        self.status = ttk.Label(self, text="Arrastra archivos a la lista o usa 'Agregar archivos'")
        self.status.pack(side="bottom", fill="x", padx=10, pady=5)
        
        self.drop_target_register('DND_Files')
        self.dnd_bind('<<Drop>>', self.on_drop)
    
    def browse_folder(self):
        folder = filedialog.askdirectory()
        if folder:
            self.target_path.set(folder)
    
    def on_drop(self, event):
        files = self.parse_dropped_files(event.data)
        for file in files:
            if file not in self.dragged_files and os.path.isfile(file):
                self.dragged_files.append(file)
                self.file_listbox.insert("end", os.path.basename(file))
        self.status.config(text=f"{len(self.dragged_files)} archivos listos para organizar")
    
    def parse_dropped_files(self, data):
        files = []
        if isinstance(data, str):
            for item in data.split():
                path = item.strip('{}')
                if os.path.exists(path):
                    files.append(path)
        elif isinstance(data, list):
            for path in data:
                if os.path.exists(path):
                    files.append(path)
        return files
    
    def add_files(self):
        files = filedialog.askopenfilenames()
        if files:
            for file in files:
                if file not in self.dragged_files:
                    self.dragged_files.append(file)
                    self.file_listbox.insert("end", os.path.basename(file))
            self.status.config(text=f"{len(self.dragged_files)} archivos listos para organizar")
    
    def remove_selected_files(self):
        selected = self.file_listbox.curselection()
        for index in selected[::-1]:
            self.file_listbox.delete(index)
            self.dragged_files.pop(index)
        self.status.config(text=f"{len(self.dragged_files)} archivos listos para organizar")
    
    def clear_all_files(self):
        self.file_listbox.delete(0, "end")
        self.dragged_files = []
        self.status.config(text="Lista de archivos vacía")
    
    def start_organization_thread(self):
        """Inicia el proceso en un hilo separado para no bloquear la GUI"""
        if not self.target_path.get():
            messagebox.showerror("Error", "Seleccione una ubicación de destino")
            return
            
        if not self.dragged_files:
            messagebox.showerror("Error", "Agregue al menos un archivo para organizar")
            return
        
        if self.running:
            return
        
        self.running = True
        self.organize_btn.config(state="disabled")
        self.progress.set("Iniciando organización...")
        
        # Iniciar hilo
        threading.Thread(target=self.organize_files, daemon=True).start()
    
    def organize_files(self):
        """Proceso principal de organización"""
        target_path = Path(self.target_path.get())
        organized_folder = target_path / "Archivos Ordenados"
        
        # Crear carpeta principal si no existe
        if not organized_folder.exists():
            organized_folder.mkdir(parents=True, exist_ok=True)
        
        # Categorías basadas en tipo MIME
         # Categorías basadas en tipo MIME - versión ampliada
        categories = {
            # Documentos
            'application/pdf': 'Documentos',
            'application/msword': 'Documentos',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'Documentos',
            'application/vnd.oasis.opendocument.text': 'Documentos',
            'text/plain': 'Documentos',
            'application/rtf': 'Documentos',
            'application/x-tex': 'Documentos',
            'application/epub+zip': 'Documentos',
            'application/x-mobipocket-ebook': 'Documentos',
            
            # Hojas de Cálculo
            'application/vnd.ms-excel': 'Hojas de Calculo',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'Hojas de Calculo',
            'application/vnd.oasis.opendocument.spreadsheet': 'Hojas de Calculo',
            'text/csv': 'Hojas de Calculo',
            'application/vnd.ms-excel.sheet.macroEnabled.12': 'Hojas de Calculo',
            
            # Presentaciones
            'application/vnd.ms-powerpoint': 'Presentaciones',
            'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'Presentaciones',
            'application/vnd.oasis.opendocument.presentation': 'Presentaciones',
            
            # Imágenes
            'image/jpeg': 'Imagenes',
            'image/png': 'Imagenes',
            'image/gif': 'Imagenes',
            'image/bmp': 'Imagenes',
            'image/svg+xml': 'Imagenes',
            'image/tiff': 'Imagenes',
            'image/webp': 'Imagenes',
            'image/x-icon': 'Imagenes',
            'image/vnd.adobe.photoshop': 'Imagenes',
            'application/postscript': 'Imagenes',  # Archivos EPS/AI
            
            # Videos
            'video/mp4': 'Videos',
            'video/quicktime': 'Videos',
            'video/x-msvideo': 'Videos',
            'video/x-matroska': 'Videos',
            'video/x-ms-wmv': 'Videos',
            'video/webm': 'Videos',
            'video/3gpp': 'Videos',
            'video/mpeg': 'Videos',
            'video/x-flv': 'Videos',
            
            # Audio
            'audio/mpeg': 'Audio',
            'audio/wav': 'Audio',
            'audio/flac': 'Audio',
            'audio/aac': 'Audio',
            'audio/ogg': 'Audio',
            'audio/x-ms-wma': 'Audio',
            'audio/x-m4a': 'Audio',
            'audio/x-aiff': 'Audio',
            'audio/webm': 'Audio',
            'audio/midi': 'Audio',
            
            # Archivos Comprimidos
            'application/zip': 'Archivos Comprimidos',
            'application/x-rar-compressed': 'Archivos Comprimidos',
            'application/x-7z-compressed': 'Archivos Comprimidos',
            'application/x-tar': 'Archivos Comprimidos',
            'application/gzip': 'Archivos Comprimidos',
            'application/x-bzip2': 'Archivos Comprimidos',
            'application/x-lzip': 'Archivos Comprimidos',
            'application/x-xz': 'Archivos Comprimidos',
            
            # Ejecutables
            'application/vnd.microsoft.portable-executable': 'Ejecutables',
            'application/x-msdownload': 'Ejecutables',
            'application/x-msi': 'Ejecutables',
            'application/x-msdos-program': 'Ejecutables',
            'application/x-sh': 'Ejecutables',
            'application/x-executable': 'Ejecutables',
            'application/x-apple-diskimage': 'Ejecutables',  # DMG para Mac
            
            # Código
            'text/x-python': 'Codigo',
            'application/javascript': 'Codigo',
            'text/html': 'Codigo',
            'text/css': 'Codigo',
            'application/json': 'Codigo',
            'application/xml': 'Codigo',
            'text/x-c': 'Codigo',
            'text/x-c++': 'Codigo',
            'text/x-java': 'Codigo',
            'text/x-php': 'Codigo',
            'text/x-ruby': 'Codigo',
            'text/x-shellscript': 'Codigo',
            'text/x-perl': 'Codigo',
            'text/x-sql': 'Codigo',
            'text/x-swift': 'Codigo',
            'text/x-typescript': 'Codigo',
            
            # Bases de datos
            'application/x-sqlite3': 'Bases de Datos',
            'application/x-netcdf': 'Bases de Datos',
            'application/x-msaccess': 'Bases de Datos',
            
            # Fuentes
            'font/ttf': 'Fuentes',
            'font/otf': 'Fuentes',
            'font/woff': 'Fuentes',
            'font/woff2': 'Fuentes',
            
            # Sistemas CAD
            'application/dwg': 'CAD',
            'application/vnd.dwg': 'CAD',
            'application/vnd.autocad.dwg': 'CAD',
            'application/x-dxf': 'CAD',
            
            # E-books
            'application/vnd.amazon.ebook': 'E-books',
            
            # Virtualización
            'application/x-virtualbox-vmdk': 'Maquinas Virtuales',
            'application/x-virtualbox-ova': 'Maquinas Virtuales',
            'application/x-vhd': 'Maquinas Virtuales',
            
            # Configuraciones
            'text/x-config': 'Configuraciones',
            'text/x-ini': 'Configuraciones',
            
            # Torrents
            'application/x-bittorrent': 'Torrents',
            
            # ISO y discos
            'application/x-iso9660-image': 'Imagenes de Disco',
            'application/x-cd-image': 'Imagenes de Disco',
            
            # Otros formatos específicos
            'application/vnd.ms-outlook': 'Correos Electronicos',  # Archivos PST
            'message/rfc822': 'Correos Electronicos',  # Archivos EML
            'application/vnd.android.package-archive': 'APK Android',
            'application/x-deb': 'Paquetes Debian',
            'application/x-rpm': 'Paquetes RPM',
            'application/x-apple-aspen-config': 'Configuracion macOS',
            
            # Por defecto
            'application/octet-stream': 'Otros'
        }
        
        # Contadores
        total_files = len(self.dragged_files)
        processed = 0
        duplicates = 0
        
        # Procesar cada archivo
        for file_path in self.dragged_files:
            if not self.running:
                break
                
            src = Path(file_path)
            if not src.exists():
                logging.error(f"Archivo no encontrado: {file_path}")
                continue
            
            # Determinar tipo MIME usando mimetypes
            mime_type, _ = mimetypes.guess_type(file_path)
            if mime_type is None:
                mime_type = 'application/octet-stream'  # Tipo por defecto
            
            folder_name = categories.get(mime_type, 'Otros')
            
            # Carpeta destino
            dest_folder = organized_folder / folder_name
            if not dest_folder.exists():
                dest_folder.mkdir(exist_ok=True)
            
            # Nombre destino
            dest = dest_folder / src.name
            
            # Verificar duplicados
            if dest.exists():
                # Generar nombre único
                counter = 1
                while dest.exists():
                    new_name = f"{src.stem}_{counter}{src.suffix}"
                    dest = dest_folder / new_name
                    counter += 1
                duplicates += 1
            
            # Mover o copiar (según modo)
            self.progress.set(f"Procesando: {src.name}...")
            logging.info(f"Procesando: {src.name} -> {dest}")
            
            try:
                if not self.dry_run.get() and self.running:
                    # Mover archivo
                    shutil.move(str(src), str(dest))
            except Exception as e:
                logging.error(f"Error moviendo {src}: {str(e)}")
            
            processed += 1
            self.progress.set(f"Procesados: {processed}/{total_files}")
        
        # Finalización
        if self.running:
            self.progress.set("Organización completada!")
            message = (
                f"Organización {'simulada' if self.dry_run.get() else 'completada'} con éxito!\n"
                f"Total archivos: {total_files}\n"
                f"Duplicados encontrados: {duplicates}"
            )
            messagebox.showinfo("Éxito", message)
            if not self.dry_run.get() and self.running:
                # Abrir carpeta destino
                os.startfile(organized_folder)
                # Limpiar lista
                self.after(100, self.clear_all_files)
        else:
            self.progress.set("Organización cancelada")
        
        self.running = False
        self.organize_btn.config(state="normal")
    
    def on_closing(self):
        """Manejar cierre de ventana durante operación"""
        if self.running:
            if messagebox.askokcancel("Salir", "La organización está en progreso. ¿Desea cancelar y salir?"):
                self.running = False
                self.destroy()
        else:
            self.destroy()

if __name__ == "__main__":
    app = FileOrganizerApp()
    app.protocol("WM_DELETE_WINDOW", app.on_closing)
    app.mainloop()