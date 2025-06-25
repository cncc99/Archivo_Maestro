import tkinter as tk
from tkinter import ttk, filedialog, messagebox, Listbox, Scrollbar, StringVar, BooleanVar
from tkinterdnd2 import TkinterDnD, DND_FILES
import os
import shutil
import logging
from pathlib import Path
import mimetypes
import hashlib  # Para detección real de duplicados
import threading
import time
from datetime import datetime
from PIL import Image  # Para análisis de imágenes y miniaturas
import pdfminer.high_level  # Para análisis de contenido en PDFs
import json  # Para reglas personalizadas

# Configuración de logging
logging.basicConfig(
    filename='archivo_maestro.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Inicializar mimetypes
mimetypes.init()

# Perfiles de usuario preconfigurados
USER_PROFILES = {
    "estudiante": {
        "categorias": ["Clases", "Tareas", "Proyectos", "Investigación"],
        "plantilla": "academica"
    },
    "investigador": {
        "categorias": ["Artículos", "Datos", "Publicaciones", "Conferencias"],
        "plantilla": "cientifica"
    },
    "administrador": {
        "categorias": ["Facturas", "Contratos", "Reportes", "Presentaciones"],
        "plantilla": "empresarial"
    }
}

class FileOrganizerApp(TkinterDnD.Tk):
    def __init__(self):
        super().__init__()
        self.title("Archivo Maestro - Organizador Inteligente")
        self.geometry("900x750")
        self.configure(bg="#f0f0f0")
        
        # Variables
        self.target_path = StringVar(value="")
        self.dragged_files = []
        self.dry_run = BooleanVar(value=False)
        self.progress = StringVar(value="Listo")
        self.running = False
        self.user_profile = StringVar(value="estudiante")
        self.rollback_stack = []  # Para sistema de deshacer
        
        # Cargar reglas personalizadas
        self.load_custom_rules()
        
        # Crear widgets
        self.create_widgets()
    
    def load_custom_rules(self):
        """Carga reglas personalizadas desde archivo"""
        try:
            with open('reglas.json', 'r') as f:
                self.custom_rules = json.load(f)
        except:
            self.custom_rules = {
                "patrones": {
                    "Tesis": ["tesis_", "investigacion_", "proyectofinal_"],
                    "Facturas": ["factura_", "boleta_", "recibo_"]
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
        
        # Sección de perfil de usuario
        profile_frame = ttk.LabelFrame(main_frame, text="Perfil de Usuario")
        profile_frame.pack(fill="x", pady=5)
        
        ttk.Label(profile_frame, text="Seleccione su perfil:").grid(row=0, column=0, padx=5, pady=5, sticky="w")
        
        profile_combo = ttk.Combobox(
            profile_frame, 
            textvariable=self.user_profile,
            values=list(USER_PROFILES.keys()),
            state="readonly",
            width=15
        )
        profile_combo.grid(row=0, column=1, padx=5, pady=5, sticky="w")
        profile_combo.bind("<<ComboboxSelected>>", self.update_profile)
        
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
            text="Generar Reporte Educativo", 
            command=self.generate_educational_report,
            width=20
        ).pack(side="left", padx=5)
        
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
    
    def update_profile(self, event=None):
        """Actualiza la interfaz según el perfil seleccionado"""
        profile = self.user_profile.get()
        self.status.config(text=f"Perfil activo: {profile} - {USER_PROFILES[profile]['plantilla'].capitalize()}")
    
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
        try:
            if file_path.lower().endswith('.pdf'):
                # Extraer texto de PDF
                text = pdfminer.high_level.extract_text(file_path)
                if "tesis" in text.lower():
                    context = "Tesis"
                elif "factura" in text.lower():
                    context = "Facturas"
            
            elif file_path.lower().endswith(('.txt', '.docx')):
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read(1000)  # Leer solo los primeros 1000 caracteres
                    if "proyecto" in content.lower():
                        context = "Proyectos"
                    elif "investigacion" in content.lower():
                        context = "Investigación"
        
        except Exception as e:
            logging.error(f"Error analizando contenido: {str(e)}")
        
        return context
    
    def organize_files(self):
        target_path = Path(self.target_path.get())
        organized_folder = target_path / "Archivos Organizados"
        
        # Crear carpeta principal si no existe
        if not organized_folder.exists():
            organized_folder.mkdir(parents=True, exist_ok=True)
        
        # Obtener perfil seleccionado
        profile = self.user_profile.get()
        profile_categories = USER_PROFILES[profile]["categorias"]
        
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
            if context and context in profile_categories:
                folder_name = context
            elif 'document' in mime_type:
                folder_name = "Documentos"
            elif 'image' in mime_type:
                folder_name = "Imagenes"
                # Generar miniatura
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
        
        # Generar reporte educativo automático
        self.generate_educational_report(organized_folder, total_files, duplicates)
        
        self.running = False
        self.organize_btn.config(state="normal")
    
    def generate_thumbnail(self, image_path, base_folder):
        """Genera miniatura para imágenes"""
        try:
            img = Image.open(image_path)
            img.thumbnail((100, 100))
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
    
    def generate_educational_report(self, organized_folder, total_files, duplicates):
        """Genera reporte educativo con estadísticas y sugerencias"""
        report_path = organized_folder / "Reporte_Educativo.html"
        
        # Estadísticas básicas
        stats = {
            "total": total_files,
            "duplicados": duplicates,
            "espacio_ahorrado": duplicates * 5,  # Estimado 5MB por archivo
            "categorias": {}
        }
        
        # Calcular estadísticas por categoría
        for item in organized_folder.iterdir():
            if item.is_dir():
                stats["categorias"][item.name] = len(list(item.iterdir()))
        
        # Generar HTML del reporte
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("<html><head><title>Reporte Educativo - Archivo Maestro</title>")
            f.write("<style>body {font-family: Arial; margin: 20px;}</style></head><body>")
            f.write("<h1>Reporte de Organización</h1>")
            
            # Estadísticas
            f.write("<h2>Estadísticas</h2>")
            f.write(f"<p>Total archivos organizados: <b>{stats['total']}</b></p>")
            f.write(f"<p>Duplicados detectados: <b>{stats['duplicados']}</b></p>")
            f.write(f"<p>Espacio estimado ahorrado: <b>{stats['espacio_ahorrado']} MB</b></p>")
            
            # Distribución por categorías
            f.write("<h3>Distribución por Categorías</h3><ul>")
            for categoria, cantidad in stats["categorias"].items():
                f.write(f"<li>{categoria}: {cantidad} archivos</li>")
            f.write("</ul>")
            
            # Sugerencias educativas
            f.write("<h2>Sugerencias para Mejorar</h2>")
            f.write("<div style='background-color:#f9f9f9; padding:15px; border-radius:5px;'>")
            
            if duplicates > 0:
                f.write("<h3>Gestión de Duplicados</h3>")
                f.write("<p>Se detectaron archivos duplicados. Recomendaciones:</p>")
                f.write("<ul>")
                f.write("<li>Revisa periódicamente la carpeta 'DUPLICADOS'</li>")
                f.write("<li>Usa nombres descriptivos para evitar crear múltiples copias</li>")
                f.write("<li>Considera un sistema de versionado (ej: documento_v1.pdf)</li>")
                f.write("</ul>")
            
            if stats["categorias"].get("Otros", 0) > 5:
                f.write("<h3>Archivos no Clasificados</h3>")
                f.write("<p>Tienes varios archivos en la categoría 'Otros'. Sugerencias:</p>")
                f.write("<ul>")
                f.write("<li>Revisa estos archivos para determinar su contenido real</li>")
                f.write("<li>Crea reglas personalizadas para estos tipos de archivos</li>")
                f.write("</ul>")
            
            f.write("<h3>Mejora Continua</h3>")
            f.write("<ul>")
            f.write("<li>Organiza tus archivos al menos una vez por semana</li>")
            f.write("<li>Usa el perfil adecuado para tu tipo de trabajo</li>")
            f.write("<li>Revisa los reportes periódicamente para identificar patrones</li>")
            f.write("</ul>")
            
            f.write("</div></body></html>")
        
        messagebox.showinfo(
            "Reporte Generado", 
            f"Se ha creado un reporte educativo en:\n{report_path}"
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