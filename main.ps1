# Variable global para almacenar la ruta de las canciones
$global:dir_canciones = "Powershell_proyecto_3T\canciones"
# Evento media
$global:evento_media = $null
# Booleano cancion en marcha:
$global:reproduccion = $false
# Booleano repetir:
$global:repetir = $false
# indice cancion
$global:indice = 0
# Cargar libreria Windows Forms
Add-Type -AssemblyName System.Windows.Forms
# Libreria para media player
Add-Type -AssemblyName presentationCore

# Función para crear el formulario
function CrearFormulario {
    $formulario = New-Object System.Windows.Forms.Form
    $formulario.Text = "YTMP3Player"
    $formulario.Size = New-Object System.Drawing.Size(540, 300)
    $formulario.StartPosition = "CenterScreen"
    return $formulario
}

# Creo checkbox
function CrearCheckbox {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = New-Object System.Drawing.Point(120, 100)
    $checkbox.Size = New-Object System.Drawing.Size(200, 200)
    $checkbox.Text = "Repetir"
    return $checkbox
}

# Función para crear un botón
function CrearBoton {
    param (
        [string]$Texto,
        [int]$X,
        [int]$Y,
        [int]$Ancho,
        [int]$Alto
    )
    $boton = New-Object System.Windows.Forms.Button
    $boton.Location = New-Object System.Drawing.Point($X, $Y)
    $boton.Size = New-Object System.Drawing.Size($Ancho, $Alto)
    $boton.Text = $Texto
    return $boton
}

# Función para crear un textarea
function CrearCuadroTexto {
    $textarea = New-Object System.Windows.Forms.TextBox
    $textarea.Location = New-Object System.Drawing.Point(50, 50)
    $textarea.Size = New-Object System.Drawing.Size(200, 20)
    return $textarea
}

# Función para crear una etiqueta "label"
function CrearEtiqueta {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Bienvenido a YTMP3Player:"
    $label.Size = New-Object System.Drawing.Size(230, 40)
    $label.Location = New-Object System.Drawing.Point(50, 10)
    return $label
}

# Función para crear un campo multiselector (listbox)
function CrearListBox {
    $multiselector = New-Object System.Windows.Forms.ListBox
    $multiselector.Location = New-Object System.Drawing.Point(50, 90)
    $multiselector.Size = New-Object System.Drawing.Size(200, 100)
    $multiselector.SelectionMode = 'MultiExtended'

    foreach ($cancion in $canciones) { # Itero sobre la lista de canciones
        # Meto cada cancion de la lista
        [void] $multiselector.Items.Add($cancion)
    }

    return $multiselector
}

# Función para mostrar el formulario y manejar el evento click de los botones y checkbox
function MostrarFormulario {
    param (
        [System.Windows.Forms.Form]$Form,
        [System.Windows.Forms.Button]$Boton_play,
        [System.Windows.Forms.Button]$Boton_stop,
        [System.Windows.Forms.Button]$Boton_sig,
        [System.Windows.Forms.Button]$Boton_rand,
        [System.Windows.Forms.TextBox]$InputBox,
        [System.Windows.Forms.ListBox]$ListBox,
        [System.Windows.Forms.CheckBox]$Checkbox
    )
    
    # Evento boton play
    $Boton_play.Add_Click({
        if ($global:reproduccion -eq $false) {
            $InputText = $InputBox.Text
            $cancion_seleccionada = $ListBox.SelectedItems
            $global:reproduccion = $true
            ReproducirCanciones $canciones $cancion_seleccionada $reproductor
        } else {
            Write-Host "Dale stop primero..."
        }

    })

    # Evento boton stop
    $Boton_stop.Add_Click({
        Write-Host "STOP CANCION..."
        $reproductor.Stop()
        $global:reproduccion = $false
        $global:evento_media = $false

    })

    # Evento boton siguiente
    $Boton_sig.Add_Click({
        # índice del elemento seleccionado actual
        $indice = $ListBox.SelectedIndex
    
        # ¿hay un siguiente elemento en la lista?
        if ($indice -lt $ListBox.Items.Count-1) {
            # siguiente elemento
            $cancion_siguiente = $ListBox.Items[$indice + 1]
    
            # deseleccionar todos
            $ListBox.ClearSelected()
    
            # selecciono el siguiente
            $ListBox.SelectedIndex = $indice + 1
    
            Write-Host "SIGUIENTE CANCION..."
            $reproductor.Stop()
            $global:reproduccion = $false
            $global:evento_media = $false
            ReproducirCanciones $canciones $cancion_siguiente $reproductor
        } else {
            Write-Output "No hay más elementos en la lista."
        }
    })

    # Evento boton aleatorio
    $Boton_rand.Add_Click({
        $n_rand = Get-Random -Minimum 0 -Maximum $ListBox.Items.Count
        $cancion_rand = $ListBox.Items[$n_rand]

        # deseleccionar todos
        $ListBox.ClearSelected()
        # selecciono el index aleatorio
        $ListBox.SelectedIndex = $n_rand
        Write-Host "CANCION ALEATORIA..."
        $reproductor.Stop()
        $global:reproduccion = $false
        $global:evento_media = $false
        ReproducirCanciones $canciones $cancion_rand $reproductor
    })

    # Evento checkbox cambiado
    $checkbox.Add_CheckedChanged({
        if ($checkbox.Checked) {
            $global:repetir = $true
        } else {
            $global:repetir = $false
        }
    })

    # Muestro el formulario
    $Form.ShowDialog() | Out-Null
}

function SeleccionarCarpeta {
    # Creo obj FolderBrowserDialog
    $folder_browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folder_browser.Description = "Selecciona la carpeta que contiene las canciones"

    # Mustro el diálogo
    $dialog_res = $folder_browser.ShowDialog()

    # Compruebo si el usuario selecciona una carpeta
    if ($dialog_res -eq [System.Windows.Forms.DialogResult]::OK) {
        $dir = $folder_browser.SelectedPath
        Write-Host "La ruta seleccionada es: $dir"
    } else {
        Write-Host "No se seleccionó ninguna carpeta."
    }
}

function RepetirCancion {
    $reproductor.Position = [TimeSpan]::Zero
    $reproductor.Play()
}

function ReproducirCanciones {
    param (
        [array]$canciones,
        [string]$nom_cancion,
        [object]$reproductor
    )

    # Obtengo el índice de la canción
    $indice = -1
    foreach ($cancion in $canciones) {
        $indice++
        if ($cancion.Name -eq $nom_cancion) {
            break
        }
    }
    $global:indice = $indice

    # Función para reproducir una canción específica
    function ReproducirCancion {
        $cancion = $canciones[$indice]
        $label.Text = "Reproduciendo ahora: $($cancion.Name)" # Cambio texto del label
        $reproductor.Open($cancion.FullName)
        $reproductor.Play()
    }

    # Manejar el evento MediaEnded para reproducir la siguiente canción cuando la actual termina
    $reproductor.add_MediaEnded({
        $indice = $global:indice
        # Si repetir es true:
        if ($global:repetir -eq $true) { # Recursividad
            $cancion = $canciones[$indice]
            ReproducirCanciones -canciones $canciones -nom_cancion $cancion.Name -reproductor $reproductor
            return
        }

        if ($indice -lt ($canciones.Count - 1)) {
            $indice++
            $siguiente_cancion = $canciones[$indice]
            Write-Host "Reproduciendo siguiente canción: $($siguiente_cancion.Name)"
            ReproducirCanciones -canciones $canciones -nom_cancion $siguiente_cancion.Name -reproductor $reproductor
        } else {
            Write-Host "No hay más canciones para reproducir."
        }
    })

    ReproducirCancion
}

$canciones = Get-ChildItem -Path $global:dir_canciones -Filter *.mp3

# Creo los obj y muestro el formulario
$form = CrearFormulario
$boton_play = CrearBoton -Texto "Play" -X 320 -Y 100 -Ancho 90 -Alto 30
$boton_stop = CrearBoton -Texto "Stop" -X 320 -Y 149 -Ancho 90 -Alto 30
$boton_aleatorio = CrearBoton -Texto "Aleatorio" -X 405 -Y 100 -Ancho 90 -Alto 30
$boton_siguiente = CrearBoton -Texto "Siguiente" -X 405 -Y 149 -Ancho 90 -Alto 30
$inputBox = CrearCuadroTexto
$label = CrearEtiqueta
$listBox = CrearListBox
$checkbox = CrearCheckbox

# Agrego al formulario
$form.Controls.Add($boton_play)
$form.Controls.Add($boton_stop)
$form.Controls.Add($boton_aleatorio)
$form.Controls.Add($boton_siguiente)
$form.Controls.Add($inputBox)
$form.Controls.Add($label)
$form.Controls.Add($listBox)
$form.Controls.Add($checkbox)



$reproductor = New-Object System.Windows.Media.MediaPlayer
MostrarFormulario $form $boton_play $boton_stop $boton_siguiente $boton_aleatorio $inputBox $listBox $checkbox
