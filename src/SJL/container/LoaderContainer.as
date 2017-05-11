package SJL.container
{
	import SJL.events.LoaderContainerEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**在完成加载外部调用SWF的时候发生*/
	[Event(name = "up_data_flash" , type = "SJL.events.LoaderContainerEvent")]
	
	
	/**
	 * ...
	 * @author CatmimiGod
	 */
	public class LoaderContainer extends BaseContainer
	{
		/**加载loader*/
		private var _loader:Loader = new Loader();
		/**路径*/
		private var _url:String = null;
		/**对象*/
		private var _obj:Object = null;
		/**容器*/
		private var _con:Sprite = new Sprite();
		
		public function LoaderContainer()
		{
			this.addChild(_con);
		}
		
		/**
		 * 加载
		 * @param	url
		 */
		public function load(url:String,obj:Object = null):void
		{
			_url = url;
			_obj = obj;
			_loader.load(new URLRequest(url));
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE , onCompleteLoadComplete);
		}
		
		/**
		 * 完成加载
		 * @param	e
		 */
		private function onCompleteLoadComplete(e:Event):void
		{
			clear();
			
			if (_loader.content is MovieClip)
			{
				loadSWF();
			}
			else if (_loader.content is Bitmap)
			{
				loadIMG();
			}
		}
		
		/**
		 * 加载swf
		 */
		private function loadSWF():void
		{
			var mc:MovieClip = _loader.content as MovieClip;
			_con.addChild(mc);
			setObject(_obj);
			this.dispatchEvent(new LoaderContainerEvent(LoaderContainerEvent.UP_DATA_FLASH));
		}
		
		/**
		 * 调用方法
		 * @param	obj
		 */
		public function setObject(obj:Object = null):void
		{
			_obj = obj;
			var mc:MovieClip = content as MovieClip;
			if (_obj != null)
			{
				var func:String = null;
				var args:String = null;
				for (var str:String in _obj)
				{
					switch(str)
					{
						case "func":
							func = _obj[str];
							break;
						case "args":
							args = _obj[str];
							break;
					}
				}
				AS.callProperty(mc, func, args, true);
			}
		}
		
		/**
		 * 加载图片
		 */
		private function loadIMG():void
		{
			var bm:Bitmap = _loader.content as Bitmap;
			bm.smoothing = true;
			_con.addChild(bm);
			this.dispatchEvent(new LoaderContainerEvent(LoaderContainerEvent.UP_DATA_IMG));
		}
		
		/**
		 * 清空
		 */
		public function clear():void
		{
			if (_con.numChildren > 0)
			{
				_con.removeChildren();
			}
		}
		
		/**
		 * 当前对象
		 */
		public function get content():DisplayObject
		{
			if (_con.numChildren > 0)
			{
				return _con.getChildAt(0) as DisplayObject;
			}
			else
			{
				return null;
			}
		}
		
		/************************************改变层级****************************************/
		
		override public function get numChildren():int 
		{
			return _con.numChildren;
		}
		
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void 
		{
			_con.removeChildren(beginIndex, endIndex);
		}
	}

}