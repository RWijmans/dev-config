# Pad naar installatie
$OdooPath = "C:\Dev\Odoo18"
$PythonExe = "python"

# 1. Download Odoo 18 van GitHub
Write-Host "Cloning Odoo 18 repository..."
if (!(Test-Path $OdooPath)) {
    git clone --branch 18.0 https://github.com/odoo/odoo.git $OdooPath
} else {
    Write-Host "Odoo-map bestaat al, overslaan."
}

# 2. Maak virtuele omgeving
Write-Host "Creating virtual environment..."
Set-Location $OdooPath
if (!(Test-Path "$OdooPath\venv")) {
    & $PythonExe -m venv venv
}

# 3. Activeer virtuele omgeving
Write-Host "Activating virtual environment..."
& "$OdooPath\venv\Scripts\activate"

# 4. Installeer dependencies
Write-Host "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# 5. Maak custom_addons-map
Write-Host "Creating custom_addons folder..."
if (!(Test-Path "$OdooPath\custom_addons")) {
    New-Item -ItemType Directory -Path "$OdooPath\custom_addons"
}

# 6. Maak configuratiebestand odoo.conf
Write-Host "Creating odoo.conf..."
$ConfContent = @"
[options]
addons_path = $OdooPath\odoo\addons,$OdooPath\custom_addons
db_host = localhost
db_port = 5432
db_user = odoo
db_password = jouw_wachtwoord
xmlrpc_port = 8069
"@
$ConfContent | Out-File "$OdooPath\odoo.conf" -Encoding UTF8

Write-Host "Odoo 18 installatie voltooid!"
Write-Host "Start Odoo met: python odoo-bin -c odoo.conf"
Write-Host "Ga naar: http://localhost:8069/web"
Write-Host "Maak een database zonder demo data (vink 'Load demonstration data' uit)."