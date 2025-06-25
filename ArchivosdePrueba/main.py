from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from jnius import autoclass, cast
from android.permissions import request_permissions, Permission
import os
import time

# Solicitar permisos al iniciar
request_permissions([Permission.RECORD_AUDIO, Permission.WRITE_EXTERNAL_STORAGE])

# Clases de Android
MediaRecorder = autoclass('android.media.MediaRecorder')
AudioSource = autoclass('android.media.MediaRecorder$AudioSource')
OutputFormat = autoclass('android.media.MediaRecorder$OutputFormat')
AudioEncoder = autoclass('android.media.MediaRecorder$AudioEncoder')
Environment = autoclass('android.os.Environment')

class AudioRecorderApp(App):
    def build(self):
        self.layout = BoxLayout(orientation='vertical')
        
        self.status_label = Label(text="Presiona REC para grabar")
        self.record_btn = Button(text="REC", size_hint=(1, 0.5))
        self.record_btn.bind(on_press=self.toggle_recording)
        
        self.layout.add_widget(self.status_label)
        self.layout.add_widget(self.record_btn)
        
        self.recorder = None
        self.is_recording = False
        self.audio_file = None
        
        return self.layout

    def toggle_recording(self, instance):
        if not self.is_recording:
            self.start_recording()
            self.record_btn.text = "DETENER"
            self.status_label.text = "Grabando..."
        else:
            self.stop_recording()
            self.record_btn.text = "REC"
            self.status_label.text = f"Grabado: {os.path.basename(self.audio_file)}"

    def start_recording(self):
        try:
            # Configurar grabador
            self.recorder = MediaRecorder()
            self.recorder.setAudioSource(AudioSource.MIC)
            self.recorder.setOutputFormat(OutputFormat.MPEG_4)
            self.recorder.setAudioEncoder(AudioEncoder.AAC)
            
            # Crear ruta de archivo
            downloads_dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC).getAbsolutePath()
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            self.audio_file = os.path.join(downloads_dir, f"audio_{timestamp}.mp3")
            
            self.recorder.setOutputFile(self.audio_file)
            self.recorder.prepare()
            self.recorder.start()
            self.is_recording = True
            
        except Exception as e:
            self.status_label.text = f"Error: {str(e)}"

    def stop_recording(self):
        if self.recorder:
            try:
                self.recorder.stop()
                self.recorder.release()
            finally:
                self.recorder = None
        self.is_recording = False

if __name__ == '__main__':
    AudioRecorderApp().run()