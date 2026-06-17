Write-Host "Installing Robot Framework dependencies..."
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
Write-Host "Setup complete. You can now run tests with: python -m robot -d results tests"
