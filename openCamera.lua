function openAndroidCamera()
    -- Check if we are on Android
    if love.system.getOS() ~= "Android" then
        print("Not on Android, camera not supported.")
        return
    end

    -- Import necessary Android classes
    local Intent = luajava.bindClass("android.content.Intent")
    local MediaStore = luajava.bindClass("android.provider.MediaStore")
    local Uri = luajava.bindClass("android.net.Uri")
    local Environment = luajava.bindClass("android.os.Environment")
    local File = luajava.bindClass("java.io.File")
    local System = luajava.bindClass("java.lang.System")
    local luajava = require("luajava")
    
    -- Create the Intent to take a picture
    local intent = Intent:new(MediaStore.ACTION_IMAGE_CAPTURE)
    
    -- Create a file to save the image
    local directory = Environment:getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
    directory:mkdirs()  -- Ensure the directory exists
    local fileName = "scan_remember_" .. System:currentTimeMillis() .. ".jpg"
    local photoFile = luajava.new(File, directory, fileName)
    
    -- Create URI from file
    -- For API 24+ (Android 7.0+), use FileProvider instead of Uri.fromFile
    -- local FileProvider = luajava.bindClass("androidx.core.content.FileProvider")
    -- local authority = activity:getPackageName() .. ".fileprovider"
    -- local photoUri = FileProvider:getUriForFile(activity, authority, photoFile)
    -- intent:addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
    local photoUri = Uri:fromFile(photoFile)  -- Deprecated for API 24+, but works for older versions
    
    -- Add the URI to the intent so the camera saves the full image
    intent:putExtra(MediaStore.EXTRA_OUTPUT, photoUri)
    
    -- Get the current activity
    local activity = love.window.getAndroidActivity()
    
    -- Launch the camera application
    activity:startActivity(intent)
    
    -- Store the file path for later use (e.g., to load the image in LÖVE)
    _G.lastCapturedImagePath = photoFile:getAbsolutePath()
    print("Image will be saved to: " .. _G.lastCapturedImagePath)
end

function love.touchpressed( id, x, y, dx, dy, pressure )
    openAndroidCamera()
end
