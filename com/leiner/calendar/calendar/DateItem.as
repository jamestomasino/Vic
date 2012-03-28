package com.leiner.calendar.calendar
{
	import com.leiner.events.EventsManager;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.leiner.utils.DateUtil
	/**
	 * ...
	 * @author ...Carl E. Leiner
	 */
	public class DateItem extends Sprite
	{
		private var mgr:EventsManager;
		private var app:String = getQualifiedClassName(this) + Math.random() * 5000;
		private var currentDate:Date;
		private var _date:Date;
		private var _selected:Boolean = false;	
		private var txt:TextField;
		private var backgroundColor:uint;
		private var overColor:uint;
		private var isWeekend:Boolean;
		private var isNonMonth:Boolean;
		private var isToday:Boolean;
		public function DateItem():void 
		{
			if (stage) init()
			else addEventListener(Event.ADDED_TO_STAGE, init)
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,init)
			mgr = EventsManager.getInstance()
			mgr.add([app], this, Event.REMOVED_FROM_STAGE, cleanup);	
			mgr.registerButton(this, [app], { click:getState, over:getState, out:getState } );
			addChild(txt = createText());
		}
		
		public function setData(cDate:Date,date:Date):void 
		{
			mouseEnabled = true;
			currentDate = DateUtil.cloneDate(cDate);
			_date = DateUtil.cloneDate(date);
			isToday = (getDate(date).getTime()==getToday().getTime());
			isWeekend = (_date.day == 0 || _date.day == 6);
			isNonMonth = (currentDate.month != _date.month);
			
			//set date text
			if (isWeekend && !Calendar.showWeekends) txt.text = '';
			else txt.text = date.date.toString();

			//set date text format
			if (isNonMonth && !Calendar.showNonMonthDates)
			{
				txt.text = '';
				mouseEnabled = false;
			}
			if(isToday)
				txt.setTextFormat(Calendar.todayFormat);
			else if (isWeekend && Calendar.showWeekends)
				txt.setTextFormat(Calendar.weekendFormat);	
			else	
				txt.setTextFormat(Calendar.format);
				
			if (isNonMonth)
			txt.setTextFormat(Calendar.nonMonthFormat);			
			//position text in cell	
			positionDate()

			//set background colors
			this.backgroundColor = Calendar.backgroundColor;
			this.overColor = Calendar.overColor;
			
			if (isNonMonth) {
				this.backgroundColor = Calendar.nonMonthColor;
				if (Calendar.showNonMonthDates)this.overColor = Calendar.nonMonthOverColor;
			}
			else {
				if (isToday){
					this.backgroundColor = Calendar.todayColor;
				}	
				else if (isWeekend)
				{
					this.backgroundColor = Calendar.weekendColor;
					if (Calendar.showWeekends) this.overColor = Calendar.weekendOverColor;
				}				
			}
			draw(this.backgroundColor, Calendar.backgroundAlpha);
		}		
		
		private function createText():TextField
		{
			var txt = new TextField();
			txt.autoSize = 'left';	
			return txt;
		}

		private function getState(e:MouseEvent):void
		{
			switch (e.type)
			{
				case 'mouseOver':
					if (isToday) return;
					draw(this.overColor,Calendar.overAlpha);
				break;
				case 'mouseOut':
					if (isToday) return;
					if(this.selected==false) draw(this.backgroundColor,Calendar.backgroundAlpha);
				break;
				case 'click':
					dispatchEvent(new Event(Event.SELECT));
				break;
			}
		}
		
		private function draw(color:uint,alfa:Number):void 
		{
			with (this.graphics)
			{
				clear();
				beginFill(color, alfa);
				drawRect(0, 0, Calendar.cellWidth, Calendar.cellHeight);
				endFill();
			}
		}
		
		private function getToday():Date
		{
			var now:Date=new Date()
			var today:Date=new Date(now.month+1+'/'+now.date+'/'+now.fullYear)
			return today;
		}
		
		private function getDate(date:Date):Date
		{
			var dtm:Date=DateUtil.cloneDate(date)
			var dt:Date=new Date(dtm.month+1+'/'+dtm.date+'/'+dtm.fullYear)
			return dt;
		}		
		
		public function get date():Date { return _date; }
		public function set date(value:Date):void 
		{	_date = value;	}
		
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void 
		{	_selected = value;		
			if (isToday) return;
			if (this.selected == false) draw(this.backgroundColor, Calendar.backgroundAlpha);
			else draw(this.overColor, 1);
		}

		private function positionDate():void 
		{
			var pos = Calendar.datePosition.toUpperCase();
			if (pos.indexOf('L') > -1) txt.x = 5;				
			if (pos.indexOf('C') > -1) txt.x = Calendar.cellWidth - txt.width >> 1;				
			if (pos.indexOf('R') > -1) txt.x = Calendar.cellWidth - txt.width - 5;				
			if (pos.indexOf('T') > -1) txt.y = 5;				
			if (pos.indexOf('M') > -1) txt.y = Calendar.cellHeight - txt.height >> 1;				
			if (pos.indexOf('B') > -1) txt.y = Calendar.cellHeight - txt.height - 5;				
		}
		
		private function cleanup(e:Event):void 
		{	mgr.removeGroup(app);		}
	}
}