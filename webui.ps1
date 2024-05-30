Set-PSDebug -Off;	#Quiet Powershell

#	`.` == `ls` on Windows
#	`&` == `call` and move on

if(Test-Path "webui.settings.bat"){ .\webui.settings.bat; }

## Set default values if not defined
if(-not $env:PYTHON){ $env:PYTHON = "C:\\Tools\\Python310\\python.exe"; };
if($env:GIT){ $env:GIT_PYTHON_GIT_EXECUTABLE = $env:GIT; };
if(-not $env:VENV_DIR){ $env:VENV_DIR = "${PSScriptRoot}\\venv"; };

$env:SD_WEBUI_RESTART = "tmp/restart";
$env:ERROR_REPORTING = "FALSE";

## stdout & stderr
function showOutput {
	Write-Output "exit code: $LASTEXITCODE";
	if((Get-Item "tmp/stdout.txt").length -gt 0){ 
		Write-Output "stdout:"; Get-Content "tmp/stdout.txt";
	}
	if((Get-Item "tmp/stderr.txt").length -gt 0){
		Write-Output "stderr:"; Get-Content "tmp/stderr.txt";
	}
}

## Make sure tmp exists
New-Item -ItemType Directory -Force -Path tmp;

## do we actually have Python or no:
& $env:PYTHON "" > tmp/stdout.txt 2> tmp/stderr.txt;
if($LASTEXITCODE -ne 0){
	Write-Output "Couldn't launch python";
	showOutput;
	exit $LASTEXITCODE;
}

## pip
& $env:PYTHON -m pip --help > tmp/stdout.txt 2> tmp/stderr.txt;
if($LASTEXITCODE -ne 0){
	if(-not $env:PIP_INSTALLER_LOCATION){
		showOutput;
		exit $LASTEXITCODE;
	}
	& $env:PYTHON $env:PIP_INSTALLER_LOCATION > tmp/stdout.txt 2> tmp/stderr.txt;
	if($LASTEXITCODE -ne 0){
		Write-Output "Couldn't install pip";
		showOutput;
		exit $LASTEXITCODE;
	}
}

## venv
if($env:VENV_DIR -ne "-" -and $env:SKIP_VENV -ne "1"){
	if(-not (Test-Path "$env:VENV_DIR\\Scripts\\Python.exe")){
		$RESULT_PYTH_SYS = & $env:PYTHON -c "import sys; print(sys.executable)";
		Write-Output "Creating venv in directory $env:VENV_DIR using python $RESULT_PYTH_SYS";
		& $RESULT_PYTH_SYS -m venv $env:VENV_DIR > tmp/stdout.txt 2> tmp/stderr.txt;
		if($LASTEXITCODE -ne 0){
			Write-Output "Unable to create venv in directory $env:VENV_DIR";
			showOutput;
			exit $LASTEXITCODE;
		}
	}
	$env:PYTHON = "$env:VENV_DIR\\Scripts\\Python.exe"
	Write-Output "venv $env:PYTHON"
}

## accelerate
if($env:ACCELERATE -eq "True"){
	Write-Output "Checking for accelerate";
	$env:ACCELERATE = "$env:VENV_DIR\\Scripts\\accelerate.exe";
	if(Test-Path $env:ACCELERATE){
		Write-Output "Accelerating"
		& $env:ACCELERATE launch --num_cpu_threads_per_process=6 launch.py;
		if(Test-Path "tmp/restart"){ continue };
		exit $LASTEXITCODE;
	}
}

## launch!
& $env:PYTHON launch.py @args;
if(Test-Path "tmp/restart"){ continue };
exit

Write-Output "Launch unsuccessful. Exiting.";
