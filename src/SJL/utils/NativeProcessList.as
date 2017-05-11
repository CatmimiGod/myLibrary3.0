package SJL.utils 
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	/**
	 * ...
	 * @author CatmimiGod
	 */
	public class NativeProcessList 
	{
		/**进程数组*/
		public static var ProcessList:Array = new Array;
		/**进程数组参数*/
		private static var ProcessInfoList:Array = new Array;
		
		public function NativeProcessList() 
		{
			
		}
		
		/**
		 * 创建进程
		 * @param	index			在数组中的位置,如果位置有进程,则会先关闭该进程
		 * @param	file			启动程序得file地址
		 * @param	argsVector		启动参数
		 * @param	autoStart		自动启动
		 */
		public static function buildProcess(file:File,index:int = 0,argsVector:Vector.<String> = null, autoStart:Boolean = true):void
		{
			try
			{
				if (ProcessList.length != 0 && ProcessList[index] != null)
				{
					exitProcess(index);
				}
			}
			catch(e:Error){}
			
			if (!file.exists) throw new ArgumentError("file路径错误");
			
			var process:NativeProcess = new NativeProcess();
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			processInfo.executable = file;
			processInfo.arguments = argsVector;
			
			ProcessList[index] = process;
			ProcessInfoList[index] = processInfo;
			
			if(autoStart)
				startProcess(index);
		}
		
		/**
		 * 启动进程
		 * @param	index		索引
		 */
		public static function startProcess(index:int = 0):void
		{
			if (index > ProcessList.length)
				return;
				
			if (ProcessList[index] != null && !ProcessList[index].running)
			{
				ProcessList[index].start(ProcessInfoList[index]);
			}
		}
		
		/**
		 * 退出可执行文件
		 * @param	index		索引
		 */
		public static function exitProcess(index:int = 0):void
		{
			if (index > ProcessList.length)
				return;
				
			if (ProcessList[index] != null && ProcessList[index].running)
			{
				ProcessList[index].exit(true);
			}
		}
		
		/**
		 * 关闭所有
		 */
		public static function closeAll():void
		{
			var i:int = 0;
			for (i = 0; i < ProcessList.length; i++)
			{
				try
				{
					if (ProcessList[i] != null)
					{
						var process:NativeProcess = ProcessList[i];
						process.exit(true);
					}
				}
				catch(e:Error){}
			}
			ProcessList = new Array;
			ProcessInfoList = new Array;
		}
		
	}

}