package {

  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.geom.ColorTransform;
  import flash.geom.Rectangle;
  import flash.net.URLRequest;
  import flash.system.ApplicationDomain;
  import flash.system.LoaderContext;
  import flash.system.Security;
  import flash.ui.ContextMenu;
  import flash.ui.ContextMenuItem;

  [SWF(backgroundColor="0xFFFFFFF", frameRate="31")]
  public class BetweenPageAndScreenLoader extends Sprite {

    public var CACHE_ID:String;

    [Embed(source="bps_loader.swf", symbol="bps_logo")]
    private var logo_embed:Class;

    private var light_logo:Sprite
    private var complete_logo:Sprite
    private var complete_logo_mask:Sprite

    private var loader_wrapper:Sprite
    private var loader_bounds:Rectangle
    private var loading:Boolean = false;

    private var bps_loader:Loader

    public var context_menu:ContextMenu;

    public function BetweenPageAndScreenLoader() {    
      Security.allowDomain("*.betweenpageandscreen.com")
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode="noScale"
      stage.addEventListener(Event.RESIZE, resize);
      
      CACHE_ID = stage.loaderInfo.parameters["v"] as String

      init();
      set_menu();
    }

    private function init(event:Event=null):void { 
      loader_wrapper = new Sprite
      light_logo = new logo_embed
      complete_logo = new logo_embed
      complete_logo_mask = new Sprite

      loader_wrapper.addChild(light_logo)
      loader_wrapper.addChild(complete_logo)
      loader_wrapper.addChild(complete_logo_mask)

      complete_logo.mask = complete_logo_mask

      var color:ColorTransform = new ColorTransform;
      color.color = 0xEEEEEE;
      light_logo.transform.colorTransform = color;

      stage.addChild(loader_wrapper);

      loader_bounds = light_logo.getBounds(loader_wrapper)	
      fetch_lib();
      resize();
    }

    private function fetch_lib():void {

      var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
      bps_loader = new Loader;

      var req:URLRequest = new URLRequest("swfs/lib.swf?v=" + CACHE_ID);
      bps_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, load_progress);
      bps_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, load_error);
      bps_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, lib_complete);
      bps_loader.load(req,context);

      load_progress()
    }

    private function lib_complete(event:Event=null):void {
      remove_listeners()
      stage.addChild(event.currentTarget.content);
      try {
        stage.removeChild(loader_wrapper);
      } catch (e:Error) {}
    }

    private function load_error(event:IOErrorEvent=null):void {
      remove_listeners()
    }

    private function remove_listeners():void {
      if (!bps_loader || !bps_loader.contentLoaderInfo) return;
      bps_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, load_progress);
      bps_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, load_error);
      bps_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, lib_complete);      
    }

    private function load_progress(event:ProgressEvent=null):void {
      var percent_loaded:Number = (event) ? event.bytesLoaded/event.bytesTotal : 0;	
      complete_logo_mask.graphics.clear()  
      if (percent_loaded > .99) return; 
      complete_logo_mask.graphics.beginFill(0x000000)
      complete_logo_mask.graphics.drawRect(loader_bounds.x, loader_bounds.bottom,loader_bounds.width, -loader_bounds.height*percent_loaded)
      complete_logo_mask.graphics.endFill()
    }

    private function resize(event:Event = null):void {
      graphics.clear()
      var bg_color:Number = 0xFFFFFF

      graphics.beginFill(bg_color);
      graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight)
      graphics.endFill();

      loader_wrapper.x = loader_x
      loader_wrapper.y = loader_y
    }

    private function get loader_x():Number { return ((stage.stageWidth- loader_wrapper.width)/2 ); }
    private function get loader_y():Number { return ((stage.stageHeight- loader_wrapper.height)/2); }

    private function set_menu():void {
      context_menu = new ContextMenu();
      var versionID:ContextMenuItem = new ContextMenuItem("Version");
      versionID.enabled = false;
      versionID.caption = "BPS " + CACHE_ID
      context_menu.customItems.push(versionID);
      context_menu.hideBuiltInItems();
      contextMenu = context_menu;     
    }		
  }
}
