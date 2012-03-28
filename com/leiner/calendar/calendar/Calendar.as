package com.leiner.calendar.calendar
{
	import com.leiner.events.EventsManager;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getQualifiedClassName;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.leiner.utils.DateUtil
	 	 	
	/**
	 * ...
	 * @author ...Carl E. Leiner
	 */
	public class Calendar extends Sprite
	{
		//PUBLIC VARIABLES_______________________________________

		public static var multipleSelect:Boolean = false;
//__________calendar variables			
		public static var backFilters:Array = [new DropShadowFilter(2)];
		public static var backCorner:Number=6
		public static var backColors = [0xcccccc, 0xFFFFFF];
		public static var backAlphas = [1, 1];
		public static var borderThickness:Number=1
		public static var borderColor:uint=0xcccccc
		public static var borderAlpha:Number = 1	
		public static var showBack:Boolean = true;
//__________weekday variables			
		public static var weekDayDisplayMode:int = 3;//-1-full.1-1letter, 3-3letter
		public static var weekDayUCase:Boolean = true;
		public static var weekDayFormat:TextFormat = new TextFormat('_sans', 12, 0xff3300, true);
//__________date cell variables		
		public static var overColor:uint = 0xccccff;
		public static var weekendColor:uint = 0xffffff;
		public static var weekendOverColor:uint = 0xccccff;
		public static var backgroundColor:uint = 0xffffff;
		public static var todayColor:uint = 0xFF3300;
		public static var nonMonthColor:uint = 0xffffff;
		public static var nonMonthOverColor:uint = 0xffffff;
		
		public static var overAlpha:Number = 1;
		public static var backgroundAlpha:Number = 1;
		
		public static var format:TextFormat = new TextFormat('_sans', 15, 0x333333);
		public static var overformat:TextFormat = new TextFormat('_sans', 15, 0x333333);
		public static var todayFormat:TextFormat = new TextFormat('_sans', 15, 0xffffff);
		public static var weekendFormat:TextFormat = new TextFormat('_sans', 15, 0x333333);
		public static var nonMonthFormat:TextFormat = new TextFormat('_sans', 13, 0x333333);
		
		public static var showWeekends:Boolean = true;
		public static var showNonMonthDates:Boolean = false;	

		public static var datePosition:String = 'mc';//tl,tc,tr,ml,mc,mr,bl,bc,br

		public static var cellWidth:int = 30;
		public static var cellHeight:int = 16;
		public static var cellPadding:int = 2;
//__________header variables		
		public static var headerFormat:TextFormat = new TextFormat('_sans', 15, 0x333333);
		public static var headerMonthDisplayMode:int = -1;//-1-full.1-1letter, 3-3letter
		public static var headerYearDisplayMode:int = -1;//-1-full.2-2number
		public static var headerHeight:int = 30;
		public static var headerButtonSize:Number = 20;
		public static var headerButtonOutlineColor:uint = 0x999999;
		public static var headerButtonOutlineAlpha:Number = 1;
		public static var headerButtonColors:Array = [0xFFFFFF,0xCCCCCC];
		public static var headerButtonAlphas:Array = [1, 1];
		public static var triangleColor:uint = 0x999999;
		public static var triangleAlpha:Number = 1;

		//PRIVATE VARIABLES_______________________________________
		private var currentDate:Date;
		private var dayLabels:Sprite;
		
		private var mgr:EventsManager;
		private var app:String = getQualifiedClassName(this) + Math.random() * 2000;;
		private var grid:Array;
        private var weekDays:Array = new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
		private var container:Sprite;
		private var firstDay:Date;
		private var firstDayColumn:uint;		
		private var maxDays:int;
		private var lastClicked;
		private var header:HeaderButtons;
		private var selectedDateArray:Array
		private var back:Sprite;
		
		public function Calendar():void 
		{
			if (stage) init()
			else addEventListener(Event.ADDED_TO_STAGE,init)
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,init)
			mgr = EventsManager.getInstance()
			mgr.add([app], this, Event.REMOVED_FROM_STAGE, cleanup);
			currentDate = getToday();
			addChild(header = new HeaderButtons());
			header.date = currentDate;
			header.x =header.y = 5;
			mgr.add([app], header, Event.CHANGE, getNewDate);

			makeGrid(7, 6, 0, 0);
			addChild(dayLabels = new Sprite());
			dayLabels.x = 5;

			
			addChild(container = new Sprite())
			container.x = 5;
			makeDaysLabels();
			container.y =dayLabels.y+dayLabels.height+7;
			makeDateCells();
			if (showBack) makeBack();
			populateCalendar(new Date());
			selectedDateArray = [];
		}
		
		private function makeBack():void
		{
			addChildAt(back = new Sprite(),0);
			var matrix:Matrix = new Matrix();
			back.graphics.clear();
			matrix.createGradientBox((cellWidth+cellPadding) * 7 + 10-cellPadding, headerHeight, Math.PI * ( 90) / 180);
			back.graphics.beginGradientFill(GradientType.LINEAR, backColors, backAlphas, [0, 255], matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB, 0);
			if (borderThickness == 0)
			{
				back.graphics.lineStyle();
			}
			else
			{
				back.graphics.lineStyle(borderThickness, borderColor, borderAlpha, true);
			}
			back.graphics.drawRoundRect(0, 0, (cellWidth+cellPadding) * 7 + 10-cellPadding,this.height+15, backCorner);
			back.graphics.moveTo(0, headerHeight+10);
			back.graphics.lineTo((cellWidth+cellPadding) * 7 + 10-cellPadding, headerHeight+10);
			back.graphics.endFill();
			back.filters = backFilters;

		}	
		
		
		//------------create calendar
		private function makeGrid (cols:int, rows:int,  x:Number = 0, y:Number = 0) {
			grid = new Array(numCells);
			var numCells:int = cols * rows;
			var curx:Number = x;
			
			for (var i:int = 0; i < numCells; i ++) {
				grid[i] = {x:curx, y:y};
				curx += (cellWidth + cellPadding);
				if (!((i + 1) % cols)) {
					curx = x;
					y += (cellHeight + cellPadding);
				}
			}
		}		
		
		private function makeDaysLabels():void {
			Calendar.weekDayFormat.align = 'center';
			//Add week day names
			var mode = weekDayDisplayMode;
			for (var i:int = 0; i < 7; i++)	{
				var dayLabel:TextField = new TextField();
				with (dayLabel)
				{
					autoSize = 'left';
					width = cellWidth;
					mouseEnabled = false;
					text = (mode == -1)?weekDays[i]:(mode == 3)?weekDays[i].substr(0, 3):weekDays[i].charAt(0);
				}
				if (weekDayUCase) dayLabel.text = dayLabel.text.toUpperCase();
				dayLabel.setTextFormat(Calendar.weekDayFormat);
				dayLabel.x = grid[i].x+(Calendar.cellWidth-dayLabel.width>>1);
				dayLabels.addChild(dayLabel);
			}
			dayLabels.y = header.height+10;
		}
		
		private function makeDateCells():void
		{
			for (var i:int = 0; i < 42; i++) {
				var item
				container.addChild(item = new DateItem());
				mgr.add([app],item,Event.SELECT,getSelection)
				item.x = grid[i].x;
				item.y = grid[i].y;
			}	
		}
		//------------create calendar
		//------------fill in dates
		private function populateCalendar(date:Date):void
		{
			firstDay = DateUtil.getFirstDay(date);
			firstDayColumn = firstDay.day;
			//get max days for current month 
			maxDays =DateUtil.maxdays(date)//tmp.date			
			//get column number for first day of the month
			//when last date of previous month is on saturday then move to second row
			if (firstDay.day == 0)
				firstDayColumn = firstDay.day + 7;
			else
				firstDayColumn = firstDay.day;				
			
			currentDate = DateUtil.cloneDate(firstDay);
			var genDate:Date=DateUtil.cloneDate(firstDay)
			for (var i:int = 0; i < maxDays; i++) {
				var item=DateItem(container.getChildAt(i + firstDayColumn))
				item.setData(currentDate, genDate)
				item.selected = isSelected(item.date);
				
				genDate.date += 1;
			}
			prevMonthDates();
			nextMonthDates();
		}

		private function prevMonthDates():void {
			var prevMonthFirstDay:Date = new Date(firstDay.fullYear,firstDay.month,firstDay.date - 1);
			var genDate:Date = DateUtil.cloneDate (prevMonthFirstDay);
			for (var i:int = firstDayColumn-1; i >= 0; i--) {		
				DateItem(container.getChildAt(i)).setData(currentDate, genDate)
				genDate.date -= 1;				
			}
		}
		
		private function nextMonthDates():void {
			var genDate:Date = DateUtil.cloneDate (firstDay)
			genDate.date += maxDays;
			for (var i:int = 1; i < (42 - maxDays - (firstDayColumn - 1)); i++) {
				DateItem(container.getChildAt((firstDayColumn-1) + i + maxDays)).setData(currentDate, genDate)
				genDate.date += 1;				
			}
		}		
		//------------fill in dates
		//-----------handlers
		private function getNewDate(e:Event):void
		{	populateCalendar(e.target.date);	}
		
		private function getSelection(e:Event):void
		{
			var di:DateItem = DateItem(e.target);
				switch(multipleSelect)
				{
					case true:
						if (di.selected) 
						{
							di.selected = false
							removeFromSelectedArray(di.date)
						}
						else 
						{
							di.selected = true
							selectedDateArray.push(di.date)
						}
					break;
					case false:
						if (lastClicked)
							lastClicked.selected = false;
					
						di.selected = true
						selectedDateArray = [di.date]
						lastClicked=di
					break;
				}
				dispatchEvent(e)			
		}
		//-----------handlers
		//-----------utilities
		private function removeFromSelectedArray(date:Date):void 
		{
			for (var i:uint = 0; i < selectedDateArray.length;i++)
			{
				if (date.getTime() == selectedDateArray[i].getTime())
				{
					selectedDateArray.splice(i, 1)
					break;
				}
			}
		}	
		
		private function isSelected (date:Date):Boolean
		{
			for each(var item in selectedDateArray)
				if (date.getTime() == item.getTime()) return true;
			return false;
		}		
		
		private function clearAll():void 
		{
			selectedDateArray = [];
			for each(var item in container)
			DateItem(item).selected = false;
			populateCalendar(currentDate);
		} 

		private function getToday():Date
		{
			var now:Date=new Date()
			var today:Date=new Date(now.month+1+'/'+now.date+'/'+now.fullYear)
			return today;
		}	
		//-----------utilities
		//------------getters/setters
		public function get date():Date { return currentDate ; }
		public function set date(value:Date):void 
		{
			currentDate = DateUtil.cloneDate(value);
			populateCalendar(currentDate);
			header.date = currentDate;
		}
		
		public function set selectedDates(val:Array):void
		{
			var arr:Array = [];
			for each(var item in val)
			{
				try { arr.push(DateUtil.cloneDate(item)) } catch (e) { };
			}
			selectedDateArray = arr
			populateCalendar(currentDate)
		}
		
		public function get selectedDates():Array
		{
			if (selectedDateArray)
			return selectedDateArray
			
			return([new Date()])
		}
		
		public function set selectedDate(val:Date):void
		{
			if (!multipleSelect) selectedDateArray = [];
			selectedDateArray.push(DateUtil.cloneDate(val))
			populateCalendar(currentDate)
		}
		
		public function get selectedDate():Date
		{
			if (selectedDateArray)
			return selectedDateArray[0]
			
			return(new Date())
		}
		//------------getters/setters
		//------------cleanup
		private function cleanup(e:Event):void 
		{	mgr.removeGroup(app);		}
	}
}