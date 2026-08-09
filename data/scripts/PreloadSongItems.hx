
import haxe.io.Path;
import sys.FileSystem;

using StringTools;

function grabImages(path) {
    var path = "menus/shop/" + path + "_images/";
    var folderPath = Paths.getAssetsRoot() + "/images/" + path;
    if (!FileSystem.exists(folderPath) || !FileSystem.isDirectory(folderPath)) return;
    var files = FileSystem.readDirectory(folderPath);
    for(file in files) {
        //making sure it doesn't think the folder is a graphic
        if(file.endsWith(".png") && file.contains(".")) {
            file = file.substr(0, file.lastIndexOf("."));
            graphicCache.cache(Paths.image(path + file));
        }
    }

}

function image(type, name) {
    return Paths.image("menus/shop/" + type + "s_images/" + name);
}

function preloadCDs() {
    grabImages("cds");
}

function preloadKeys() {
    grabImages("keys");
}