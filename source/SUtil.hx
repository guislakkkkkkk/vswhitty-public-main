package;

#if android
import android.AndroidTools;
import android.stuff.Permissions;
#end
import lime.app.Application;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Assets;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;

/**
 * author: Saw (M.A. Jigsaw)
 */

class SUtil
{
    #if android
    private static var aDir:String = null;
    private static var sPath:String = AndroidTools.getExternalStorageDirectory();  
    private static var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions();  
    private static var cutscenesArr:Array<String> = ["anthropophobia", "genocide", "lmao_undyne_fucking_dies", "pacifist", "psychoticbreakdown", "redmegalovania", "themurderer", "themurderer2"];
    #end

    public static var getIaPath:String = lime.system.System.applicationStorageDirectory;

    static public function getPath():String
    {
    	#if android
        if (aDir != null && aDir.length > 0) 
        {
            return aDir;
        } 
        else 
        {
            aDir = sPath + "/" + "." + Application.current.meta.get("file") + "/files/";         
        }
        return aDir;
        #else
        return "";
        #end
    }

    static public function doTheCheck()
    {
        #if android
        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
                AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
            }  
        }

        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
                SUtil.applicationAlert("Permissions", "If you accepted the permisions for storage, good, you can continue, if you not the game can't run without storage permissions please grant them in app settings" + "\n" + "Press Ok To Close The App");
            } else {
                SUtil.applicationAlert("Permissions", "The Game can't run without storage permissions please grant them in app settings" + "\n" + "Press Ok To Close The App");
            }
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file"))){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file"));
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file") + "/files")){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file") + "/files");
        }

        if (!FileSystem.exists(SUtil.getPath() + "log")){
            FileSystem.createDirectory(SUtil.getPath() + "log");
        }

        if (!FileSystem.exists(SUtil.getPath() + "system-saves")){
            FileSystem.createDirectory(SUtil.getPath() + "system-saves");
        }

        if (!FileSystem.exists(SUtil.getPath() + "assets")){
            FileSystem.createDirectory(SUtil.getPath() + "assets");
        }

        if (!FileSystem.exists(SUtil.getPath() + "assets/replays")){
            FileSystem.createDirectory(SUtil.getPath() + "assets/replays");
        }

	if (!FileSystem.exists(SUtil.getPath() + 'assets/videos')) {
	    FileSystem.createDirectory(SUtil.getPath() + 'assets/videos');
	}

	for (vid in cutscenesArr) {
		Saver.save(Paths.video(vid), SUtil.getPath() + Paths.video(vid));
	}
        #end
    }

    //Thanks Forever Engine
    static public function gameCrashCheck(){
    	Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
    }
     
    static public function onCrash(e:UncaughtErrorEvent):Void {
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        var dateNow:String = Date.now().toString();
        dateNow = StringTools.replace(dateNow, " ", "_");
        dateNow = StringTools.replace(dateNow, ":", "'");
        var path:String = "log/" + "crash_" + dateNow + ".txt";
        var errMsg:String = "";

        for (stackItem in callStack)
        {
            switch (stackItem)
            {
                case FilePos(s, file, line, column):
                    errMsg += file + " (line " + line + ")\n";
                default:
                    Sys.println(stackItem);
            }
        }

        errMsg += e.error;

        if (!FileSystem.exists(SUtil.getPath() + "log")){
            FileSystem.createDirectory(SUtil.getPath() + "log");
        }

        sys.io.File.saveContent(SUtil.getPath() + path, errMsg + "\n");
        
        Sys.println(errMsg);
        Sys.println("Crash dump saved in " + Path.normalize(path));
        Sys.println("Making a simple alert ...");

        SUtil.applicationAlert("Uncaught Error :(, The Call Stack: ", errMsg);
        flash.system.System.exit(0);
    }
	
    public static function applicationAlert(title:String, description:String){
        Application.current.window.alert(description, title);
    }

    static public function saveContent(fileName:String = "file", fileExtension:String = ".json", fileData:String = "you forgot something to add in your code"){
        if (!FileSystem.exists(SUtil.getPath() + "system-saves")){
            FileSystem.createDirectory(SUtil.getPath() + "system-saves");
        }

        sys.io.File.saveContent(SUtil.getPath() + "system-saves/" + fileName + fileExtension, fileData);
        #if android
        SUtil.applicationAlert("Done Action: ", "File Saved Successfully!");
        #end
    }
}

class Saver {
    static public function save(copyPath:String, savePath:String) {
        if (!FileSystem.exists(savePath)){
	    var bytes = OpenFlAssets.getBytes(copyPath);
	    sys.io.File.saveBytes(savePath, bytes);
        }
    }
}
