import tkinter as tk
from tkinter import ttk, filedialog, messagebox, Listbox, Scrollbar, StringVar, BooleanVar
from tkinterdnd2 import TkinterDnD, DND_FILES
import os
import shutil
import logging
from pathlib import Path
import mimetypes
import hashlib
import threading
from datetime import datetime
from PIL import Image
import pdfminer.high_level
import json

# Configuración de logging
logging.basicConfig(
    filename='archivo_maestro.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Inicializar mimetypes
mimetypes.init()

class FileOrganizerApp(TkinterDnD.Tk):
    def __init__(self):
        super().__init__()
        self.title("Archivo Maestro - Organizador Inteligente")
        self.geometry("900x650")
        self.configure(bg="#f0f0f0")
        
        # Variables
        self.target_path = StringVar(value="")
        self.dragged_files = []
        self.dry_run = BooleanVar(value=False)
        self.progress = StringVar(value="Listo")
        self.running = False
        self.rollback_stack = []  # Para sistema de deshacer
        
        # Definir reglas directamente en el código
        self.reglas = self.definir_reglas_por_defecto()
        
        # Crear widgets
        self.create_widgets()
    
    def definir_reglas_por_defecto(self):
        """Define las reglas directamente en el código sin archivo externo"""
        return {
            "categorias": ["Documentos", "Imágenes", "Videos", "Audio", "Otros"],
            "patrones_contexto": {
                "Tesis": ["tesis", "trabajo de grado", "investigación"],
                "Facturas": ["factura", "comprobante", "recibo"],
                "Proyectos": ["proyecto", "entregable", "avance"],
                "Examen": ["examen", "prueba", "evaluación"]
            },
            "configuracion_avanzada": {
                "generar_miniaturas": True,
                "tamaño_miniatura": 128,
                "limite_duplicados": 3,
                "comprimir_duplicados": True
            }
        }
    
    def create_widgets(self):
        style = ttk.Style()
        style.theme_use("vista")
        style.configure("TFrame", background="#f0f0f0")
        style.configure("TLabel", background="#f0f0f0", font=("Segoe UI", 9))
        style.configure("TButton", font=("Segoe UI", 9))
        style.configure("Title.TLabel", font=("Segoe UI", 14, "bold"))
        style.configure("Section.TLabelframe.Label", font=("Segoe UI", 10, "bold"))
        style.configure("Accent.TButton", background="#4CAF50", foreground="white")
        style.map("Accent.TButton", background=[("active", "#45a049")])
        
        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        ttk.Label(main_frame, text="ARCHIVO MAESTRO", style="Title.TLabel").pack(pady=(0, 10))
        ttk.Label(main_frame, text="Organizador Inteligente de Archivos", font=("Segoe UI", 10)).pack(pady=(0, 15))
        
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
        
        # Modo de prueba y operaciones
        action_frame = ttk.Frame(location_frame)
        action_frame.grid(row=1, column=0, columnspan=3, pady=5, sticky="w")
        
        ttk.Checkbutton(
            action_frame,
            text="Modo prueba (no mueve archivos)",
            variable=self.dry_run
        ).pack(side="left", padx=5)
        
        ttk.Button(
            action_frame,
            text="Deshacer última operación",
            command=self.undo_last_operation
        ).pack(side="left", padx=10)
        
        # Área de arrastre (más grande y destacada)
        drop_frame = ttk.LabelFrame(main_frame, text="Arrastra aquí los archivos a organizar", padding=10)
        drop_frame.pack(fill="both", expand=True, pady=10, ipady=20)
        
        list_frame = ttk.Frame(drop_frame)
        list_frame.pack(fill="both", expand=True, padx=5, pady=5)
        
        scrollbar = Scrollbar(list_frame)
        scrollbar.pack(side="right", fill="y")
        
        self.file_listbox = Listbox(
            list_frame,
            selectmode=tk.EXTENDED,
            height=15,
            bg="white",
            relief="sunken",
            yscrollcommand=scrollbar.set,
            font=("Segoe UI", 10)
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
        
        # Botones de acción principal
        action_btn_frame = ttk.Frame(main_frame)
        action_btn_frame.pack(fill="x", pady=10)
        
        self.organize_btn = ttk.Button(
            action_btn_frame, 
            text="Organizar Archivos", 
            style="Accent.TButton",
            command=self.start_organization_thread,
            width=20
        )
        self.organize_btn.pack(side="left", padx=5)
        
        ttk.Button(
            action_btn_frame, 
            text="Generar Reporte", 
            command=lambda: self.generate_educational_report(),
            width=20
        ).pack(side="left", padx=5)
        
        # Barra de progreso
        self.progress_frame = ttk.Frame(main_frame)
        self.progress_frame.pack(fill="x", pady=5)
        
        self.progress_label = ttk.Label(self.progress_frame, textvariable=self.progress)
        self.progress_label.pack(fill="x", pady=5)
        
        # Barra de estado
        self.status = ttk.Label(self, text="Arrastra archivos al área superior o usa 'Agregar archivos'")
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
    
    def get_file_hash(self, file_path):
        """Calcula hash SHA256 para detección de duplicados"""
        hasher = hashlib.sha256()
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                hasher.update(chunk)
        return hasher.hexdigest()
    
    def extract_content_context(self, file_path):
        """Intenta determinar el contexto del archivo por su contenido"""
        context = None
        nombre_archivo = os.path.basename(file_path).lower()
        
        # Primero verificar por nombre de archivo
        for contexto, patrones in self.reglas["patrones_contexto"].items():
            for patron in patrones:
                if patron in nombre_archivo:
                    return contexto
        
        try:
            # Verificar por contenido en archivos de texto
            if file_path.lower().endswith('.pdf'):
                text = pdfminer.high_level.extract_text(file_path).lower()
                for contexto, patrones in self.reglas["patrones_contexto"].items():
                    for patron in patrones:
                        if patron in text:
                            return contexto
            
            elif file_path.lower().endswith(('.txt', '.docx', '.odt')):
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read(1000).lower()  # Leer solo los primeros 1000 caracteres
                    for contexto, patrones in self.reglas["patrones_contexto"].items():
                        for patron in patrones:
                            if patron in content:
                                return contexto
        
        except Exception as e:
            logging.error(f"Error analizando contenido: {str(e)}")
        
        return context
    
    def organize_files(self):
        target_path = Path(self.target_path.get())
        organized_folder = target_path / "Archivos Organizados"
        
        # Crear carpeta principal si no existe
        if not organized_folder.exists():
            organized_folder.mkdir(parents=True, exist_ok=True)
        
        # Categorías básicas
        categorias = self.reglas["categorias"]
        
        # Contadores
        total_files = len(self.dragged_files)
        processed = 0
        duplicates = 0
        hashes_seen = set()
        
        # Procesar cada archivo
        for file_path in self.dragged_files:
            if not self.running:
                break
                
            src = Path(file_path)
            if not src.exists():
                logging.error(f"Archivo no encontrado: {file_path}")
                continue
            
            # Determinar tipo MIME
            mime_type, _ = mimetypes.guess_type(file_path)
            if mime_type is None:
                mime_type = 'application/octet-stream'
            
            # Detectar contexto por contenido
            context = self.extract_content_context(file_path)
            
            # Determinar categoría
            if context and context in categorias:
                folder_name = context
            elif 'document' in mime_type:
                folder_name = "Documentos"
            elif 'image' in mime_type:
                folder_name = "Imágenes"
                # Generar miniatura si está habilitado
                if self.reglas["configuracion_avanzada"]["generar_miniaturas"]:
                    self.generate_thumbnail(src, organized_folder)
            elif 'video' in mime_type:
                folder_name = "Videos"
            elif 'audio' in mime_type:
                folder_name = "Audio"
            else:
                folder_name = "Otros"
            
            # Carpeta destino
            dest_folder = organized_folder / folder_name
            if not dest_folder.exists():
                dest_folder.mkdir(exist_ok=True)
            
            # Calcular hash para detección de duplicados
            file_hash = self.get_file_hash(file_path)
            is_duplicate = file_hash in hashes_seen
            hashes_seen.add(file_hash)
            
            # Nombre destino
            if is_duplicate:
                dest = dest_folder / f"{src.stem}_DUPLICADO{src.suffix}"
                duplicates += 1
            else:
                dest = dest_folder / src.name
            
            # Registrar operación para posible rollback
            self.rollback_stack.append((str(src), str(dest)))
            
            # Mover o copiar (según modo)
            self.progress.set(f"Procesando: {src.name}...")
            logging.info(f"Procesando: {src.name} -> {dest}")
            
            try:
                if not self.dry_run.get() and self.running and not is_duplicate:
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
                f"Duplicados detectados: {duplicates}"
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
    
    def generate_thumbnail(self, image_path, base_folder):
        """Genera miniatura para imágenes"""
        try:
            img = Image.open(image_path)
            size = self.reglas["configuracion_avanzada"]["tamaño_miniatura"]
            img.thumbnail((size, size))
            thumb_folder = base_folder / "Miniaturas"
            if not thumb_folder.exists():
                thumb_folder.mkdir()
            thumb_path = thumb_folder / f"thumb_{image_path.name}"
            img.save(thumb_path, "JPEG")
        except Exception as e:
            logging.error(f"Error generando miniatura: {str(e)}")
    
    def undo_last_operation(self):
        """Deshace la última operación de organización"""
        if not self.rollback_stack:
            messagebox.showinfo("Información", "No hay operaciones para deshacer")
            return
        
        src, dest = self.rollback_stack.pop()
        
        try:
            if Path(dest).exists():
                shutil.move(dest, src)
                messagebox.showinfo("Éxito", f"Archivo restaurado: {Path(src).name}")
            else:
                messagebox.showwarning("Advertencia", "El archivo destino ya no existe")
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo deshacer: {str(e)}")
    
    def generate_educational_report(self, organized_folder=None, total_files=0, duplicates=0):
        """Genera reporte con estadísticas y sugerencias"""
        if not organized_folder:
            if not self.target_path.get():
                messagebox.showerror("Error", "Primero seleccione una ubicación de destino")
                return
            organized_folder = Path(self.target_path.get()) / "Archivos Organizados"
        
        report_path = organized_folder / "Reporte_Organizacion.html"
        
        # Estadísticas básicas
        stats = {
            "total": total_files or len(self.dragged_files),
            "duplicados": duplicates,
            "categorias": {}
        }
        
        # Calcular estadísticas por categoría
        for item in organized_folder.iterdir():
            if item.is_dir():
                stats["categorias"][item.name] = len(list(item.iterdir()))
        
        # Generar HTML del reporte
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("<html><head><title>Reporte - Archivo Maestro</title>")
            f.write("<style>body {font-family: Arial; margin: 20px;}</style></head><body>")
            f.write("<h1>Reporte de Organización</h1>")
            
            # Estadísticas
            f.write("<h2>Estadísticas</h2>")
            f.write(f"<p>Total archivos organizados: <b>{stats['total']}</b></p>")
            f.write(f"<p>Duplicados detectados: <b>{stats['duplicados']}</b></p>")
            
            # Distribución por categorías
            f.write("<h3>Distribución por Categorías</h3><ul>")
            for categoria, cantidad in stats["categorias"].items():
                f.write(f"<li>{categoria}: {cantidad} archivos</li>")
            f.write("</ul>")
            
            f.write("</body></html>")
        
        messagebox.showinfo(
            "Reporte Generado", 
            f"Se ha creado un reporte en:\n{report_path}"
        )
    
    def on_closing(self):
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