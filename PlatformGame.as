﻿package {	import flash.display.*;	import flash.events.*;	import flash.text.*;	import flash.utils.getTimer;		public class PlatformGame extends MovieClip {		// movement constants		static const gravity:Number = .004;				// screen constants		static const edgeDistance:Number = 200;		static const vertDistance:Number = 150;		// object arrays		private var fixedObjects:Array;		private var solidObjects:Array;		private var otherObjects:Array;		private var ladderObjects:Array;		private var ladderTopObjects:Array;		private var deathObjects:Array;		private var backgroundObjects:Array;				// hero and enemies and objects		private var hero:Object;		private var enemies:Array;				// game state		private var playerObjects:Array;		private var gameScore:int;		private var gameMode:String = "start";		private var playerLives:int;		private var lastTime:Number = 0;				// double jump		private var spacePressedNum:int;				// Parallax scrolling 		private var moveBackUp:Boolean;		private var moveBackDown:Boolean;		private var moveBackLeft:Boolean;		private var moveBackRight:Boolean;				// start game		public function startPlatformGame() {			playerObjects = new Array();			gameScore = 0;			gameMode = "play";			playerLives = 3;		}				// start level		public function startGameLevel() {						// create characters			createHero();			addEnemies();						// examine level and note all objects			examineLevel();						// add listeners			this.addEventListener(Event.ENTER_FRAME,gameLoop);			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpFunction);						// set game state			gameMode = "play";			addScore(0);			showLives();		}				// creates the hero object and sets all properties		public function createHero() {			hero = new Object();			hero.mc = gamelevel.hero;			hero.dx = 0.0;			hero.dy = 0.0;			hero.inAir = false;			hero.direction = 1;			hero.animstate = "stand";			hero.walkAnimation = new Array(2,3,4,5,6,7,8);			hero.animstep = 0;			hero.jump = false;			hero.moveLeft = false;			hero.moveRight = false;			hero.isSprinting = false;			hero.onLadder = false;			hero.ladderMain = false;			hero.ladderTop = false;			hero.climbUp = false;			hero.climbDown = false;			hero.climbSpeed = .01;			hero.jumpSpeed = .8;			hero.walkSpeed = .2;			hero.sprintSpeed = .35;			hero.width = 20.0;			hero.height = 40.0;			hero.startx = hero.mc.x;			hero.starty = hero.mc.y;		}				// finds all enemies in the level and creates an object for each		public function addEnemies() {			enemies = new Array();			var i:int = 1;			while (true) {				if (gamelevel["enemy"+i] == null) break;				var enemy = new Object();				enemy.mc = gamelevel["enemy"+i];				enemy.dx = 0.0;				enemy.dy = 0.0;				enemy.inAir = false;				enemy.direction = 1;				enemy.animstate = "stand"				enemy.walkAnimation = new Array(2,3,4,5);				enemy.animstep = 0;				enemy.jump = false;				enemy.moveRight = true;				enemy.moveLeft = false;				enemy.climbUp = false;				enemy.climbDown = false;				enemy.jumpSpeed = 1.0;				enemy.walkSpeed = .08;				enemy.width = 30.0;				enemy.height = 30.0;				enemies.push(enemy);				i++;			}		}				// look at all level children and note walls, floors, items, ladders, and spikes		public function examineLevel() {						fixedObjects = new Array();			solidObjects = new Array();			otherObjects = new Array();			ladderObjects = new Array();			ladderTopObjects = new Array();			deathObjects = new Array();			backgroundObjects = new Array();						for(var i:int=0;i<this.gamelevel.numChildren;i++) {				var mc = this.gamelevel.getChildAt(i);								// add floors and walls to fixedObjects				if ((mc is Floor) || (mc is Wall)) {					var floorObject:Object = new Object();					floorObject.mc = mc;					floorObject.leftside = mc.x;					floorObject.rightside = mc.x+mc.width;					floorObject.topside = mc.y;					floorObject.bottomside = mc.y+mc.height;					fixedObjects.push(floorObject);								} else if (mc is Block) {					var solidObject:Object = new Object();					solidObject.mc = mc;					solidObject.leftside = mc.x;					solidObject.rightside = mc.x+mc.width;					solidObject.topside = mc.y;					solidObject.bottomside = mc.y+mc.height;					solidObjects.push(solidObject);								// add treasure, key and door to otherOjects				} else if ((mc is Treasure) || (mc is Key) || (mc is Door) || (mc is Chest)) {					otherObjects.push(mc);								// add ladders to ladderObjects				} else if (mc is Ladder) {					var ladderObject:Object = new Object();					ladderObject.mc = mc;					ladderObject.leftside = mc.x - mc.width/2;					ladderObject.rightside = mc.x + mc.width/2;					ladderObject.topside = mc.y - mc.height;					ladderObject.bottomside = mc.y;					ladderObjects.push(ladderObject);								} else if (mc is LadderTop) {					var ladderTopObject:Object = new Object();					ladderTopObject.mc = mc;					ladderTopObject.leftside = mc.x - mc.width/2;					ladderTopObject.rightside = mc.x + mc.width/2;					ladderTopObject.topside = mc.y - mc.height;					ladderTopObject.bottomside = mc.y;					ladderTopObjects.push(ladderTopObject);				} else if (mc is Spikes) {					deathObjects.push(mc);				} else if ((mc is Back1) || (mc is Back2) || (mc is Stars) || (mc is Trees1) || (mc is Trees2)) {					backgroundObjects.push(mc);				}			}		}				// note key presses, set hero properties		public function keyDownFunction(event:KeyboardEvent) {			 // don't move until in play mode			if (gameMode != "play") return;			// Move left w/ left arrow or A 			if ((event.keyCode == 37) || (event.keyCode == 65)) {				hero.moveLeft = true;				// Hero not on ladder if moving left				hero.onLadder = false; 			// Move right w/ right arrow or D			} else if ((event.keyCode == 39) || (event.keyCode == 68)) {				hero.moveRight = true;				// Hero not on ladder if moving right				hero.onLadder = false;  			// Jump			} else if (event.keyCode == 32) {				if (!hero.inAir) {					hero.jump = true;					spacePressedNum = 1;								// double Jump				} else if (spacePressedNum == 1) {					hero.jump = true;					spacePressedNum = 0;				}						// Sprinting			} else if (event.keyCode == 16) { 				hero.isSprinting = true;						// Climb up ladder w/ up arrow or W			} else if ((event.keyCode == 38) || (event.keyCode == 87)) { 				hero.climbUp = true;						// Climb down ladder w/ down arrow or S			} else if ((event.keyCode == 40) || (event.keyCode == 83)) {				hero.climbDown = true;			}					}				public function keyUpFunction(event:KeyboardEvent) {			if ((event.keyCode == 37) || (event.keyCode == 65)) {				hero.moveLeft = false;			} else if ((event.keyCode == 39) || (event.keyCode == 68)) {				hero.moveRight = false;			} else if (event.keyCode == 16) {				hero.isSprinting = false;			} else if ((event.keyCode == 38) || (event.keyCode == 87)) {				hero.climbUp = false;			} else if ((event.keyCode == 40) || (event.keyCode == 83)) {				hero.climbDown = false;			}		}				// perform all game tasks		public function gameLoop(event:Event) {						// get time differentce			if (lastTime == 0) lastTime = getTimer();			var timeDiff:int = getTimer()-lastTime;			lastTime += timeDiff;						// only perform tasks if in play mode			if (gameMode == "play") {				moveCharacter(hero,timeDiff);				moveEnemies(timeDiff);				checkCollisions();				scrollWithHero();				parallaxScroll();				climbLadder();			}		}				// loop through all enemies and move them		public function moveEnemies(timeDiff:int) {			for(var i:int=0;i<enemies.length;i++) {								// move				moveCharacter(enemies[i],timeDiff);								// if hit a wall, turn around				if (enemies[i].hitWallRight) {					enemies[i].moveLeft = true;					enemies[i].moveRight = false;				} else if (enemies[i].hitWallLeft) {					enemies[i].moveLeft = false;					enemies[i].moveRight = true;				}			}		}				// primary function for character movement		public function moveCharacter(char:Object,timeDiff:Number) {			if (timeDiff < 1) return;						// react to changes from key presses			var horizontalChange = 0;			var newAnimState:String = "stand";			var newDirection:int = char.direction;						if (char.moveLeft) {				// walk left				horizontalChange = -char.walkSpeed*timeDiff;				char.dx = -char.walkSpeed*timeDiff;				newAnimState = "walk";				newDirection = -1;				if (char.isSprinting) { 					horizontalChange = -char.sprintSpeed*timeDiff;				} 			} else if (char.moveRight) {				// walk right				horizontalChange = char.walkSpeed*timeDiff;				char.dx = -char.walkSpeed*timeDiff;				newAnimState = "walk";				newDirection = 1;				if (char.isSprinting) {					horizontalChange = char.sprintSpeed*timeDiff;				}			}									if (char.onLadder) {				// If on ladder, gravity does not pull down				var verticalChange:Number = char.dy*timeDiff;							} else if (!char.onLadder) {				// assume character pulled down by gravity				verticalChange = char.dy*timeDiff + timeDiff*gravity;				if (verticalChange > 13.0) verticalChange = 13.0;				char.dy += timeDiff*gravity;			}						if (char.jump) {				// start jump				char.jump = false;				char.dy = -char.jumpSpeed;				verticalChange = -char.jumpSpeed;				newAnimState = "jump";			} 					// assume no wall hit, and hanging in air			char.hitWallRight = false;			char.hitWallLeft = false;			char.inAir = true;						// find new vertical position			var newY:Number = char.mc.y + verticalChange;															// loop through all fixed objects to see if character has landed BLOCKS COLLISION 			for(var i:int=0;i<fixedObjects.length;i++) {				// if character is on the top of the ladder then he can pass through the top of the blocks 				if (char.ladderTop) {					break;				// if character is not on ladderTop then he won't fall through the floor				} else {					// check to see if character is standing between the left and right side of the object					if ((char.mc.x+char.width/2 > fixedObjects[i].leftside) && (char.mc.x-char.width/2 < fixedObjects[i].rightside)) {						// Stop character from falling through the floor						if ((char.mc.y <= fixedObjects[i].topside) && (newY > fixedObjects[i].topside)) {							newY = fixedObjects[i].topside;							char.dy = 0;							char.inAir = false;							break;								    }					}				} 			}						// loop through all the solid objects to see if character is jumping up into or landed			for(i=0;i<solidObjects.length;i++) {				// if character is on the top of the ladder then he can pass through the top of the blocks 				if (char.ladderTop) {					break;				} else if (char.ladderMain) {					// check to see if character is standing between the left and right side of the object					if ((char.mc.x+char.width/2 > solidObjects[i].leftside) && (char.mc.x-char.width/2 < solidObjects[i].rightside)) {						// Stop character from falling through floor						if ((char.mc.y <= solidObjects[i].topside) && (newY > solidObjects[i].topside)) {							newY = solidObjects[i].topside;							char.dy = 0;							char.inAir = false;							break;						}					}				} else {					// check to see if character is standing between the left and right side of the object					if ((char.mc.x+char.width/2 > solidObjects[i].leftside) && (char.mc.x-char.width/2 < solidObjects[i].rightside)) {						// Stop character from falling through floor						if ((char.mc.y <= solidObjects[i].topside) && (newY > solidObjects[i].topside)) {							newY = solidObjects[i].topside;							char.dy = 0;							char.inAir = false;							break;						}						// Stop character from jumping through the bottom of the object						if ((char.mc.y - char.height >= solidObjects[i].bottomside) && (newY - char.height < solidObjects[i].bottomside)) {							newY = solidObjects[i].bottomside + char.height;							char.dy = .5;							char.inAir = true;						}					}				}			}									// find new horizontal position			var newX:Number = char.mc.x + horizontalChange;								// Climbing the ladder - Char is colliding with ladder and not jumping			if (char.canClimb && !char.jump) {				// if Up key pressed - Climb up				if (char.climbUp) {					char.onLadder = true;					char.dy = -char.climbSpeed*timeDiff;									// if Down key pressed - Climb down				} else if (char.climbDown) {					char.onLadder = true;					char.dy = char.climbSpeed*timeDiff;								// In order to stop the character from falling without a button press				} else if (!char.climbUp) {					char.dy = 0;					char.onLadder = true;				} else if (!char.climbDown) {					char.dy = 0;					char.onLadder = true;				}			// if no longer colliding the hero is no longer on the ladder			} else if (!char.canClimb) {					char.onLadder = false;			}						// loop through all objects to see if character has bumped into a wall			for(i=0;i<fixedObjects.length;i++) {				if ((newY > fixedObjects[i].topside) && (newY-char.height < fixedObjects[i].bottomside)) {					if ((char.mc.x-char.width/2 >= fixedObjects[i].rightside) && (newX-char.width/2 <= fixedObjects[i].rightside)) {						newX = fixedObjects[i].rightside+char.width/2;						char.hitWallLeft = true;						break;					}					if ((char.mc.x+char.width/2 <= fixedObjects[i].leftside) && (newX+char.width/2 >= fixedObjects[i].leftside)) {						newX = fixedObjects[i].leftside-char.width/2;						char.hitWallRight = true;						break;					}				}			}									// set position of character			char.mc.x = newX;			char.mc.y = newY;						// set animation state			if (char.inAir) {				newAnimState = "jump";			}			char.animstate = newAnimState;						// move along walk cycle			if (char.animstate == "walk") {				char.animstep += timeDiff/60;				if (char.animstep > char.walkAnimation.length) {					char.animstep = 0;				}				char.mc.gotoAndStop(char.walkAnimation[Math.floor(char.animstep)]);							// not walking, show stand or jump state			} else {				char.mc.gotoAndStop(char.animstate);			}						// changed directions			if (newDirection != char.direction) {				char.direction = newDirection;				char.mc.scaleX = char.direction;			}		}				public function climbLadder() {						for(var i:int=ladderTopObjects.length-1;i>=0;i--) {				if ((hero.mc.x+hero.width/2 > ladderTopObjects[i].leftside) && (hero.mc.x-hero.width/2 < ladderTopObjects[i].rightside)) {					if ((hero.mc.y > ladderTopObjects[i].topside) && (hero.mc.y < ladderTopObjects[i].bottomside)) {						if (hero.climbDown) {							hero.canClimb = true;							hero.jump = false;							hero.inAir = false;							hero.onLadder = true;							hero.ladderMain = false;							hero.ladderTop = true;							break;						}					}				} else {					hero.canClimb = false;					hero.onLadder = false;					hero.ladderTop = false;				}			}								for(i=ladderObjects.length-1;i>=0;i--) {				if ((hero.mc.x+hero.width/2 > ladderObjects[i].leftside) && (hero.mc.x-hero.width/2 < ladderObjects[i].rightside)) {					if ((hero.mc.y > ladderObjects[i].topside) && (hero.mc.y < ladderObjects[i].bottomside)) {						hero.canClimb = true;						hero.jump = false;						hero.inAir = false;						hero.onLadder = true;						hero.ladderMain = true;						hero.ladderTop = false;						break;					}				} else {					hero.canClimb = false;					hero.onLadder = false;					hero.ladderMain = false;						}			}		}				// scroll to the right or left, up or down if needed		public function scrollWithHero() { 			// Horizontal			var stagePosition:Number = gamelevel.x+hero.mc.x;			var rightEdge:Number = stage.stageWidth-edgeDistance;			var leftEdge:Number = edgeDistance;			// Vertical 			var vertPosition:Number = gamelevel.y+hero.mc.y;			var topEdge:Number = vertDistance;			var bottomEdge:Number = stage.stageHeight-vertDistance;			// Horizontal scrolling 			if (stagePosition > rightEdge) {				gamelevel.x -= (stagePosition-rightEdge);				if (gamelevel.x < -(2600-stage.stageWidth)) gamelevel.x = -(2600-stage.stageWidth);				moveBackRight = true;			} else {				moveBackRight = false;			}			if (stagePosition < leftEdge) {				gamelevel.x += (leftEdge-stagePosition);				if (gamelevel.x > 0) gamelevel.x = 0;				moveBackLeft = true;			} else {				moveBackLeft = false;			}			// Vertical scrolling			// If playing level one, vertical scrolling won't begin until character moves down ladder to Cave			if (MovieClip(root).currentFrame == 2) {				if (hero.mc.y < 400) {					gamelevel.y = 0;				} else if (hero.mc.y > 400) {					// Stage will stop scrolling at the bottom of the level					if (vertPosition > bottomEdge) {						gamelevel.y -= (vertPosition-bottomEdge);						if (gamelevel.y < -(gamelevel.height-stage.stageHeight)) gamelevel.y = -(gamelevel.height-stage.stageHeight);						moveBackDown = true;					} else {						moveBackDown = false;					}					// If in cave, vertical scrolling will stop at the top of the cave					if (vertPosition < topEdge) {						gamelevel.y += (topEdge-vertPosition);						if (gamelevel.y > -400) gamelevel.y = -400;						moveBackUp = true;					} else {						moveBackUp = false;					}				} 			} 		}				public function parallaxScroll() {			// Parallax scrolling for the backgrounds			for(var i:int=backgroundObjects.length-1;i>=0;i--) {				var pScroll:Number;				if (backgroundObjects[i] is Back1) {					backgroundObjects[i].x = hero.dx*0.8; 					backgroundObjects[i].y = hero.dy*0.8;				} else if (backgroundObjects[i] is Back2) {					pScroll = .65;				} else if (backgroundObjects[i] is Stars) {					pScroll = .35;				} 								/*if ((hero.hitWallRight) || (hero.hitWallLeft) || (hero.mc.y < 400)) {					return;				} else {									}*/								// If colliding with a wall, stop the backrgound from moving				/*if ((hero.hitWallRight) || (hero.hitWallLeft) || (hero.mc.y < 400)) {					return;				} else if (moveBackLeft && hero.moveLeft) {					if (hero.isSprinting) {						backgroundObjects[i].x += hero.sprintSpeed * pScroll;					} else {						backgroundObjects[i].x += hero.walkSpeed * pScroll;					}										} else if (moveBackRight && hero.moveRight) {					if (hero.isSprinting) {						backgroundObjects[i].x -= hero.sprintSpeed * pScroll;					} else {						backgroundObjects[i].x -= hero.walkSpeed * pScroll;					}				} 								if (moveBackDown && hero.climbDown) {					backgroundObjects[i].y -= -hero.dy * pScroll;				} else if (moveBackDown && hero.climbDown) {					backgroundObjects[i].y += hero.dy * pScroll;				}					*/			}			}				// check collisions with enemies, items		public function checkCollisions() {						// enemies			for(var i:int=enemies.length-1;i>=0;i--) {				if (hero.mc.hitTestObject(enemies[i].mc)) {										// is the hero jumping down onto the enemy?					if (hero.inAir && (hero.dy > 0)) {						enemyDie(i);					} else {						heroDie();					}				}			}						// items			for(i=otherObjects.length-1;i>=0;i--) {				if (hero.mc.hitTestObject(otherObjects[i])) {					getObject(i);				}			}						// Spikes			for(i=deathObjects.length-1;i>=0;i--) {				if (hero.mc.hitTestObject(deathObjects[i])) {					heroDie();				}			}					} 						// remove enemy		public function enemyDie(enemyNum:int) {			var pb:PointBurst = new PointBurst(gamelevel,"Got Em!",enemies[enemyNum].mc.x,enemies[enemyNum].mc.y-20);			gamelevel.removeChild(enemies[enemyNum].mc);			enemies.splice(enemyNum,1);		}				// enemy got player		public function heroDie() {			// show dialog box			var dialog:Dialog = new Dialog();			dialog.x = 175;			dialog.y = 100;			addChild(dialog);					if (playerLives == 0) {				gameMode = "gameover";				dialog.message.text = "Game Over!";			} else {				gameMode = "dead";				dialog.message.text = "He Got You!";				playerLives--;			}						hero.mc.gotoAndPlay("die");		}				// player collides with objects		public function getObject(objectNum:int) {			// award points for treasure			if (otherObjects[objectNum] is Treasure) {				var pb:PointBurst = new PointBurst(gamelevel,100,otherObjects[objectNum].x,otherObjects[objectNum].y);				gamelevel.removeChild(otherObjects[objectNum]);				otherObjects.splice(objectNum,1);				addScore(100);							// got the key, add to inventory			} else if (otherObjects[objectNum] is Key) {				pb = new PointBurst(gamelevel,"Got Key!" ,otherObjects[objectNum].x,otherObjects[objectNum].y);				playerObjects.push("Key");				gamelevel.removeChild(otherObjects[objectNum]);				otherObjects.splice(objectNum,1);							// hit the door, end level if hero has the key			} else if (otherObjects[objectNum] is Door) {				if (playerObjects.indexOf("Key") == -1) return;				if (otherObjects[objectNum].currentFrame == 1) {					otherObjects[objectNum].gotoAndPlay("opening");					levelComplete();				}							// got the chest, game won			} else if (otherObjects[objectNum] is Chest) {				otherObjects[objectNum].gotoAndStop("open");				gameComplete();			}							}				// add points to score		public function addScore(numPoints:int) {			gameScore += numPoints;			scoreDisplay.text = String(gameScore);		}				// update player lives		public function showLives() {			livesDisplay.text = String(playerLives);		}				// level over, bring up dialog		public function levelComplete() {			gameMode = "done";			var dialog:Dialog = new Dialog();			dialog.x = 175;			dialog.y = 100;			addChild(dialog);			dialog.message.text = "Level Complete!";		}				// game over, bring up dialog		public function gameComplete() {			gameMode = "gameover";			var dialog:Dialog = new Dialog();			dialog.x = 175;			dialog.y = 100;			addChild(dialog);			dialog.message.text = "You Got the Treasure!";		}				// dialog button clicked		public function clickDialogButton(event:MouseEvent) {			removeChild(MovieClip(event.currentTarget.parent));						// new life, restart, or go to next level			if (gameMode == "dead") {				// reset hero				showLives();				hero.mc.x = hero.startx;				hero.mc.y = hero.starty;				gameMode = "play";			} else if (gameMode == "gameover") {				cleanUp();				gotoAndStop("start");			} else if (gameMode == "done") {				cleanUp();				nextFrame();			}						// give stage back the keyboard focus			stage.focus = stage;		}							// clean up game		public function cleanUp() {			removeChild(gamelevel);			this.removeEventListener(Event.ENTER_FRAME,gameLoop);			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpFunction);		}			}	}