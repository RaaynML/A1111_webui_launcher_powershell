Set-PSDebug -Off;

$host.ui.RawUI.WindowTitle = "A1111-webui";
$env:PYTORCH_CUDA_ALLOC_CONF="garbage_collection_threshold:0.6,max_split_size_mb:512"

.\venv\Scripts\Activate.ps1;
#Start-Sleep -s 1

python launch.py --no-download-sd-model --opt-channelslast --unload-gfpgan --disable-nan-check --sub-quad-q-chunk-size 512 --sub-quad-kv-chunk-size 512 --sub-quad-chunk-threshold 80
