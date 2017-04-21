package SJL.display
{
	import SJL.container.LoaderContainer;
	import SJL.utils.NativeProcessList;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.template.DemoApplicationTemplate;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	
	public class ModelBase extends DemoApplicationTemplate
	{
		/**加载容器*/
		protected var _loaderContainer:LoaderContainer = new LoaderContainer();
		/**UI控制容器*/
		protected var _loaderUI:LoaderContainer = new LoaderContainer();
		/**当前索引*/
		protected var _currentPage:String = "0";
		
		public function ModelBase()
		{
			super();
		}
		
		override protected function initialize():void 
		{
			super.initialize();
			this.addChild(_loaderContainer);
			this.addChild(_loaderUI);
			if (configData.content.hasOwnProperty("@controlUI") &&configData.content.@controlUI != "")
			{
				_loaderUI.load(configData.content.@controlUI);
			}
			this.addEventListener(MouseEvent.CLICK , onClickHandler);
			this.stage.nativeWindow.addEventListener(Event.CLOSE , onCloseWindowsHandler);
			this.stage.nativeWindow.addEventListener(Event.CLOSING , onCloseWindowsHandler);
			
			if (defaultPage != null && defaultPage != "")
			{
				goPage(defaultPage);
			}
			else
			{
				home();
			}
		}
		
		/**
		 * 鼠标点击事件
		 * @param	e
		 */
		protected function onClickHandler(e:MouseEvent):void
		{
			var btnName:String = e.target.name;
			switch(btnName)
			{
				case "btn_home":
					home({func:"homeHandler"});
					break;
				case "btn_next":
					nextPage();
					break;
				case "btn_prev":
					prevPage();
					break;
				case "btn_back":
					back({func:"backHandler"});
					break;
				case "btn_close":
					this.stage.nativeWindow.close();
					break;
				case "swf_clear":
					_loaderContainer.clear();
					break;
				case "changeLanguage":
					setLanguage();
					break;
				default:
					if (btnName.indexOf("goPage_") == 0)
					{
						var arr:Array = btnName.split("_");
						var page:String;
						for (var i:int = 1; i < arr.length; i++)
						{
							if (i == 1)
							{
								page = arr[i];
							}
							else
							{
								page += "/" + arr[i];
							}
						}
						goPage(page);
					}
			}
		}
		
		/**
		 * 切换语言
		 */
		override protected function languageChanged():void 
		{
			super.languageChanged();
			goPage(_currentPage);
		}
		
		/**
		 *  去到指定界面
		 * @param	page
		 * @param	obj
		 */
		public function goPage(page:String = "0",obj:Object = null):void
		{
			var url:String = getItemUrl(page);
			/**如果有会覆盖obj的值,只允许一个启动参数*/
			var args:Object = Object(getParamsMessage("content", "item", "page", page, "@args"));
			if (url != null && url != "")
			{
				_currentPage = page;
				if (args != null)
				{
					obj = args;
				}
				_loaderContainer.load(url,obj);
			}
		}
		
		/**
		 * 在当前界面的下一页
		 * @param	obj
		 */
		public function nextPage(obj:Object = null):void
		{
			var len:int = getLength(_currentPage);
			var arr:Array = _currentPage.split("/");
			var page:String = "";
			if (int(arr[arr.length - 1]) + 1 <= len)
			{
				arr[arr.length - 1] = String(int(arr[arr.length - 1]) + 1);
				for (var i:int = 0; i < arr.length ; i++)
				{
					if (i == 0)
					{
						page = arr[i];
					}
					else
					{
						page += "/" + arr[i];
					}
				}
				goPage(page);
			}
		}
		
		/**
		 * 在当前界面的上一页
		 * @param	obj
		 */
		public function prevPage(obj:Object = null):void
		{
			var arr:Array = _currentPage.split("/");
			var page:String = "";
			
			if (int(arr[arr.length - 1]) - 1 >= 0)
			{
				arr[arr.length - 1] = String(int(arr[arr.length - 1]) - 1);
				for (var i:int = 0; i < arr.length ; i++)
				{
					if (i == 0)
					{
						page = arr[i];
					}
					else
					{
						page += "/" + arr[i];
					}
				}
				goPage(page);
			}
		}
		
		/**
		 * 返回
		 * @param	obj
		 */
		public function back(obj:Object = null):void
		{
			var arr:Array = _currentPage.split("/");
			var page:String = "";
			for (var i:int = 0; i < arr.length - 1; i++)
			{
				if (i == 0)
				{
					page = arr[i];
				}
				else
				{
					page += "/" + arr[i];
				}
			}
			goPage(page,obj);
		}
		
		/**
		 * 回主页
		 * @param	obj
		 */
		public function home(obj:Object = null):void
		{
			goPage(homePage,obj);
		}
		
		/************************************************************************************/
		
		/**
		 * 获取对象路径
		 * @param	page
		 * @param	keyName
		 * @return
		 */
		protected function getItemUrl(page:String = "0", keyName:String = "item"):String
		{
			var url:String = "";
			var arr:Array = page.split("/");
			var tempXML:XML = configData.content[0];
			for (var i:int; i < arr.length; i++)
			{
				if (tempXML.hasOwnProperty(keyName))
				{
					tempXML = tempXML[keyName].(@["page"] == arr[i])[0];
					if (tempXML != null && tempXML.hasOwnProperty("@url"))
					{
						url = tempXML.@url;
						url = url.replace(/%LANGUAGE%/ig, language);
					}
					else
					{
						url = null;
					}
				}
			}
			return url;
		}
		
		/**
		 * 获取该页面的长度
		 * @param	page
		 * @param	keyName
		 * @return
		 */
		protected function getLength(page:String = "0", keyName:String = "item"):int
		{
			var len:int = 0;
			var arr:Array = page.split("/");
			/**减少一位直接获取上一级的长度*/
			arr.pop();
			
			var tempXML:XML = configData.content[0];
			
			if (arr.length == 0)
			{
				len = tempXML[keyName].length();
			}
			
			for (var i:int = 0; i < arr.length; i++)
			{
				if (tempXML.hasOwnProperty(keyName))
				{
					tempXML = tempXML[keyName].(@["page"] == arr[i])[0];
					len = tempXML[keyName].length();
				}
			}
			return len;
		}
		
		/************************************************************************************/
		
		/**
		 * 获取对象数据
		 * @param	mainName
		 * @param	subName
		 * @param	keyName
		 * @param	key
		 * @param	params
		 * @return
		 */
		protected function getParamsMessage(mainName:String = "content", subName:String = "item", 
		keyName:String = "page" , page:String = "0" , params:String="@url"):String
		{
			var url:String = "";
			var arr:Array = page.split("/");
			var tempXML:XML = configData[mainName][0];
			for (var i:int; i < arr.length; i++)
			{
				if (tempXML.hasOwnProperty(subName))
				{
					tempXML = tempXML[subName].(@[keyName] == arr[i])[0];
					if (tempXML != null && tempXML.hasOwnProperty(params))
					{
						url = tempXML[params];
						//url = url.replace(/%LANGUAGE%/ig, language);
					}
					else
					{
						url = tempXML;
						if (url == "" || url == null)
							url = null;
					}
				}
			}
			return url;
		}
		
		/**延迟时间*/
		private var _delayTime:uint = 0;
		
		/**
		 * 启动进程
		 * @return
		 */
		public function starProcess(id = "0"):void
		{
			var url:String = getParamsMessage("process", "item", "id", id, "@url");
			var args:String = getParamsMessage("process", "item", "id", id, "@args");
			var vector:Vector.<String> = new Vector.<String>;
			
			if (url != null)
			{
				url = url.replace(/%applicationDirectory%/ig, File.applicationDirectory.nativePath);
			}
			
			if (args != null)
			{
				args = args.replace(/%applicationDirectory%/ig, File.applicationDirectory.nativePath);
				vector.push(args);
			}
			else
			{
				vector = null;
			}
			
			var file:File = new File(url);
			
			NativeProcessList.buildProcess(file, 0, vector, false);
			clearTimeout(_delayTime);
			_delayTime = setTimeout(NativeProcessList.startProcess, 100, 0);
		}
		
		/************************************************************************************/
		
		/**
		 * 主页
		 */
		protected function get homePage():String
		{
			if (configData.content.hasOwnProperty("@homePage"))
			{
				return configData.content.@homePage;
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * 默认页面
		 */
		protected function get defaultPage():String
		{
			if (configData.content.hasOwnProperty("@defaultPage"))
			{
				return configData.content.@defaultPage;
			}
			else
			{
				return null;
			}
		}
		
		/************************************************************************************/
		
		/**
		 * 当关闭窗体放生的
		 * @param	e
		 */
		protected function onCloseWindowsHandler(e:Event):void
		{
			NativeProcessList.closeAll();
		}
	}
}