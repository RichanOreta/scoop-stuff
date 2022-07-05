# Usage: scoop purge <app>
# Summary: Purges persisted data of app
# Help: e.g. scoop purge brave

$apps = $args.split()

foreach ($app in $apps)
{
    $persist_dir = persistdir $app
    if (Test-Path $persist_dir)
    {
        try
        {
            Write-Host "Removing persisted data. [$($app)]"
            Remove-Item $persist_dir -Recurse -Force -ErrorAction Stop
        } catch
        {
            error "Couldn't remove '$(friendly_path $persist_dir)'; it may be in use."
            continue
        }
    } else
    {
        error "Persist data does not exist"
    }
}
