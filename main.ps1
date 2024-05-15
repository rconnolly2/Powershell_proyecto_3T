$global:dir_canciones = $null

function PlayCanciones($canciones, $reproductor) {
    foreach ($cancion in $canciones) {
        Write-Output "Now playing: " + $cancion.Name # Concateno cadena de texto
        $reproductor.Open($cancion.FullName)
        $reproductor.Play()
        Start-Sleep -Seconds 10
        $reproductor.Stop()
    }
}

function ElegirRuta {
    Write-Host "Dame la ruta absoluta de la carpeta donde se ubiquen las canciones..."
    $global:dir_canciones = Read-Host
}

function DisplayRuta {
    Write-Host $global:dir_canciones
}

ElegirRuta()

$canciones = Get-ChildItem -Path $global:dir_canciones -Filter *.mp3

$reproductor = New-Object System.Windows.Media.MediaPlayer


