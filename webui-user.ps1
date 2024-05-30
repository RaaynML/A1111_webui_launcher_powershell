Set-PSDebug -Off;

$host.ui.RawUI.WindowTitle = "A1111-webui"
$env:PYTORCH_CUDA_ALLOC_CONF="garbage_collection_threshold:0.6,max_split_size_mb:512"
$env:SD_WEBUI_LOG_LEVEL="ERROR"

#$env:PYTHON=
#$env:GIT=
$env:VENV_DIR=".\venv"
$env:COMMANDLINE_ARGS="--theme dark --disable-nan-check --unload-gfpgan --opt-channelslast --disable-console-progressbars --sub-quad-chunk-threshold 80"

.\webui.ps1
