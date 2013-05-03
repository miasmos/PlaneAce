package com {
	import flash.events.*;
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.geom.*;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	
	public class Deck extends MovieClip {
		var bmp:Array = new Array();
		var deck:Array = new Array();
		var played:Array = new Array();
		var main;
		var tempCard:Card;
		var loadCnt:uint = 0;
		var loadTotal:uint = 100;
		
		public function Deck(gameRef) {
			main=gameRef;
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE,init);
			addEventListener(Event.ENTER_FRAME,loadChk);
			Build();
		}
		
		private function loadChk(e:Event) {
			if (Loaded()) {
				Reset();
				removeEventListener(Event.ENTER_FRAME,loadChk);
			}
		}
		
		private function Build() {
			var path:File = File.applicationDirectory.resolvePath("images");
			var images:Array = path.getDirectoryListing();
			loadTotal = images.length;
			for (var i:uint=0; i<images.length; i++) {
				trace(images[i].nativePath);
				LoadImage(images[i]);
			}
		}
		
		private function LoadImage(loadit) {
			var ldr:Loader = new Loader();
			//var image:URLRequest = new URLRequest(loadit.nativePath);
			var image:URLRequest = new URLRequest(loadit.url);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event) {
				//bmp.push(rotateBitmapData(e.target.content.bitmapData,90));
				bmp.push(e.target.content.bitmapData);
				loadCnt++;
				main.loading.textbox.text = String(Math.round((loadCnt/loadTotal)*100));
			});
			ldr.load(image);
		}
		
		public function Reset() {
			Shuffle();
			deck = new Array();
			for each (var index in bmp) {
				deck.push(new Bitmap(index));
			}
			played = new Array();
		}
		
		public function Peek(n:uint=0):Array {
			if (n != 0) {
				var temp:Array = new Array();
				for (var i:uint=0;i<n;i++) {
					temp.push(deck[i]);
				}
				return temp;
			}
			else {
				return deck;
			}
		}
		
		public function CardsLeft() {
			return deck.length;
		}
		
		public function Loaded() {
			return loadCnt == loadTotal;
		}
		
		public function Shuffle() {
			var temp:Array = new Array(bmp.length);
			var randomPos:uint = 0;
			
			for (var i:int = 0; i < temp.length; i++) {    
				randomPos = int(Math.random() * bmp.length);    
				temp[i] = bmp[randomPos];
				bmp.splice(randomPos, 1);
			}
			bmp=temp;
		}
		
		public function Draw(flipped:Boolean=true,allowMove:Boolean=false) {
			if (deck.length == 0) {Reset();}
			trace(deck.length);
			var scale:Number = stage.stageWidth/deck[0].width;
			var card = new Card(deck[0],flipped,allowMove,scale);
			deck.splice(0,1);
			played.push(card);
			return card;
		}
		
		public function CardProps() {
			return tempCard.GetBmp();
		}
		
		private function cropBitmap( _x:Number, _y:Number, _width:Number, _height:Number, displayObject:DisplayObject = null):Bitmap {
		   var cropArea:Rectangle = new Rectangle( 0, 0, _width, _height );
		   var croppedBitmap:Bitmap = new Bitmap( new BitmapData( _width, _height, true, 0x00ffffff ), PixelSnapping.ALWAYS, true );
		   croppedBitmap.bitmapData.draw( (displayObject!=null) ? displayObject : stage, new Matrix(1, 0, 0, 1, -_x, -_y) , null, null, cropArea, true );
		   return croppedBitmap;
		}
		
		function rotateBitmapData( bitmapData:BitmapData, degree:int = 0 ):BitmapData {
			var newBitmap:BitmapData = new BitmapData( bitmapData.height, bitmapData.width, true );
			var matrix:Matrix = new Matrix();
			matrix.rotate( degree * Math.PI / 180 );
			
			if ( degree == 90 ) {
				matrix.translate( bitmapData.height, 0 );
			} else if ( degree == -90 || degree == 270 ) {
				matrix.translate( 0, bitmapData.width );
			} else if ( degree == 180 ) {
				newBitmap = new BitmapData( bitmapData.width, bitmapData.height, true );
				matrix.translate( bitmapData.width, bitmapData.height );
			}
			
			newBitmap.draw( bitmapData, matrix, null, null, null, true );
			return newBitmap;
		}
		
		public function GetPlayed() {
			return played;
		}
	}
}

import flash.events.*;
import flash.display.*;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.geom.*;
	
class Card extends MovieClip {
	private var num:Number;	//numeric value	(1,2-9,10,10,10,10)
	private var flip:Boolean;
	private var bmpRef:DisplayObject;
	private var backRef:DisplayObject = new Bitmap(new Backer());
	private var isMoving:Boolean=false;
	private var allowMove:Boolean=false;
	private var size:Number;
	
	public function Card(bmp,flipped:Boolean=true,aMove=false,siz:Number=1) {
		bmp.smoothing = true;
		bmpRef=bmp;
		size=siz;
		allowMove=aMove;
		flip=flipped;
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		backRef.scaleX=0.5*size;
		backRef.scaleY=0.5*size;
		bmpRef.scaleX*=size;
		bmpRef.scaleY*=size;
		this.addChild(bmpRef);
		this.addChild(backRef);
		addEventListener(MouseEvent.MOUSE_DOWN,captureCursor);
		if (flip) {backRef.visible=false;}
		else {bmpRef.visible=false;}
	}
	
	private function captureCursor(e:MouseEvent){
		if (Moveable()) {
			isMoving=true;
			stage.addEventListener(MouseEvent.MOUSE_UP,releaseCursor);
			e.target.startDrag();
		}
	}
		
	private function releaseCursor(e:MouseEvent){
		isMoving=false;
		e.target.stopDrag();
		stage.removeEventListener(MouseEvent.MOUSE_UP,releaseCursor);
	}
	
	public function Flip() {
		bmpRef.visible = !bmpRef.visible;
		backRef.visible = !backRef.visible;
	}
	
	public function Flipped() {
		return flip;
	}
	
	public function IsMoving() {
		return isMoving;
	}
	
	public function toggleMove(a:Boolean) {
		allowMove=a;
	}
	
	public function Moveable() {
		return allowMove;
	}
	
	public function Resize(siz:Number) {
		size*=siz;
		backRef.scaleX*=size;
		backRef.scaleY*=size;
		bmpRef.scaleX*=size;
		bmpRef.scaleY*=size;
	}
	
	public function GetBmp() {
		return bmpRef;
	}
}
