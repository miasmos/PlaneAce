package com {
	import com.Deck;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	public class Main extends MovieClip{
		private var deck:Deck = new Deck(this);
		public var played;
		
		public function Main() {
			addChild(deck);
			addEventListener(Event.ENTER_FRAME,loadCheck);
		}
		
		private function loadCheck(e:Event) {
			if (deck.Loaded()) {
				removeEventListener(Event.ENTER_FRAME,loadCheck);
				setTimeout(function(backer) {
					removeChild(backer);
					stage.addEventListener(MouseEvent.CLICK,onClick);
					Play();   
				},1000,backer);
			}
		}
		
		private function onClick(e:MouseEvent) {
			Play();
		}
		
		private function Play() {
			if (played) {removeChild(played);}
			played = deck.Draw();
			addChild(played);
			played.x = (stage.stageWidth-played.width)/2+5;
			played.y = (stage.stageHeight-played.height)/2+5;
		}
	}
	
}
