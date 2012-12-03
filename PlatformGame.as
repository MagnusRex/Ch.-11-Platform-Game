﻿package {	import flash.display.*;	import flash.events.*;	import flash.text.*;	import flash.utils.getTimer;		public class PlatformGame extends MovieClip {		// movement constants		static const gravity:Number = .004;				// screen constants		static const edgeDistance:Number = 200;		// object arrays		private var fixedObjects:Array;		private var otherObjects:Array;		private var ladderObjects:Array;		private var ladderTopOb:Array;				// hero and enemies and objects		private var hero:Object;		private var enemies:Array;				// game state		private var playerObjects:Array;		private var gameScore:int;		private var gameMode:String = "start";		private var playerLives:int;		private var lastTime:Number = 0;				// double jump		private var spacePressedNum:int;				// Sprinting		static const sprintSpeed:Number = .35;				// start game		public function startPlatformGame() {			playerObjects = new Array();			gameScore = 0;			gameMode = "play";			playerLives = 3;		}				// start level		public function startGameLevel() {						// create characters			createHero();			addEnemies();						// examine level and note all objects			examineLevel();						// add listeners			this.addEventListener(Event.ENTER_FRAME,gameLoop);			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpFunction);						// set game state			gameMode = "play";			addScore(0);			showLives();		}				// creates the hero object and sets all properties		public function createHero() {			hero = new Object();			hero.mc = gamelevel.hero;			hero.dx = 0.0;			hero.dy = 0.0;			hero.inAir = false;			hero.direction = 1;			hero.animstate = "stand";			hero.walkAnimation = new Array(2,3,4,5,6,7,8);			hero.animstep = 0;			hero.jump = false;			hero.moveLeft = false;			hero.moveRight = false;			hero.isSprinting = false;			hero.onLadder = false;			//hero.ladderTop = false;			hero.climbUp = false;			hero.climbDown = false;			hero.climbSpeed = .01;			hero.jumpSpeed = .8;			hero.walkSpeed = .2;			hero.width = 20.0;			hero.height = 40.0;			hero.startx = hero.mc.x;			hero.starty = hero.mc.y;		}				// finds all enemies in the level and creates an object for each		public function addEnemies() {			enemies = new Array();			var i:int = 1;			while (true) {				if (gamelevel["enemy"+i] == null) break;				var enemy = new Object();				enemy.mc = gamelevel["enemy"+i];				enemy.dx = 0.0;				enemy.dy = 0.0;				enemy.inAir = false;				enemy.direction = 1;				enemy.animstate = "stand"				enemy.walkAnimation = new Array(2,3,4,5);				enemy.animstep = 0;				enemy.jump = false;				enemy.moveRight = true;				enemy.moveLeft = false;				enemy.climbUp = false;				enemy.climbDown = false;				enemy.jumpSpeed = 1.0;				enemy.walkSpeed = .08;				enemy.width = 30.0;				enemy.height = 30.0;				enemies.push(enemy);				i++;			}		}				// look at all level children and note walls, floors and items		public function examineLevel() {			fixedObjects = new Array();			otherObjects = new Array();			ladderObjects = new Array();			for(var i:int=0;i<this.gamelevel.numChildren;i++) {				var mc = this.gamelevel.getChildAt(i);								// add floors and walls to fixedObjects				if ((mc is Floor) || (mc is Wall)) {					var floorObject:Object = new Object();					floorObject.mc = mc;					floorObject.leftside = mc.x;					floorObject.rightside = mc.x+mc.width;					floorObject.topside = mc.y;					floorObject.bottomside = mc.y+mc.height;					fixedObjects.push(floorObject);									// add treasure, key and door to otherOjects				} else if ((mc is Treasure) || (mc is Key) || (mc is Door) || (mc is Chest)) {					otherObjects.push(mc);				// add ladders to ladderObjects				} else if (mc is Ladder) {					//var ladderObject:Object = new Object();					//ladderObject.mc = mc;					//ladderObject.leftSide = mc.x;					//ladderObject.rightSide = mc.x+mc.width;					ladderObjects.push(mc);				}/* else if (mc is LadderTop) {					var lTopObject:Object = new  Object();					lTopObject.mc = mc					ladderTopOb.push(mc);				}*/			}		}				// note key presses, set hero properties		public function keyDownFunction(event:KeyboardEvent) {						if (gameMode != "play") return; // don't move until in play mode			// Move left			if (event.keyCode == 37) {				hero.moveLeft = true;				hero.onLadder = false; // Hero not on ladder if moving left			// Move right			} else if (event.keyCode == 39) {				hero.moveRight = true;				hero.onLadder = false;  // Hero not on ladder if moving right			// Jump			} else if (event.keyCode == 32) {				if (!hero.inAir) {					hero.jump = true;					spacePressedNum = 1;								// double Jump				} else if (spacePressedNum == 1) {					hero.jump = true;					spacePressedNum = 0;				}						// Sprinting			} else if (event.keyCode == 16) { 				hero.isSprinting = true;						// Climb up ladder			} else if (event.keyCode == 38) { 				hero.climbUp = true;				//trace("climb up!");						// Climb down ladder			} else if (event.keyCode == 40) {				hero.climbDown = true;				//trace("climb down");			}					}				public function keyUpFunction(event:KeyboardEvent) {			if (event.keyCode == 37) {				hero.moveLeft = false;			} else if (event.keyCode == 39) {				hero.moveRight = false;			} else if (event.keyCode == 16) {				hero.isSprinting = false;			} else if (event.keyCode == 38) {				hero.climbUp = false;			} else if (event.keyCode == 40) {				hero.climbDown = false;			}		}				// perform all game tasks		public function gameLoop(event:Event) {						// get time differentce			if (lastTime == 0) lastTime = getTimer();			var timeDiff:int = getTimer()-lastTime;			lastTime += timeDiff;						// only perform tasks if in play mode			if (gameMode == "play") {				moveCharacter(hero,timeDiff);				moveEnemies(timeDiff);				checkCollisions();				scrollWithHero();			}		}				// loop through all enemies and move them		public function moveEnemies(timeDiff:int) {			for(var i:int=0;i<enemies.length;i++) {								// move				moveCharacter(enemies[i],timeDiff);								// if hit a wall, turn around				if (enemies[i].hitWallRight) {					enemies[i].moveLeft = true;					enemies[i].moveRight = false;				} else if (enemies[i].hitWallLeft) {					enemies[i].moveLeft = false;					enemies[i].moveRight = true;				}			}		}				// primary function for character movement		public function moveCharacter(char:Object,timeDiff:Number) {			if (timeDiff < 1) return;						if (char.onLadder) {				// No gravity 				var verticalChange:Number = char.dy*timeDiff;			} else if (!char.onLadder) {				// assume character pulled down by gravity				verticalChange = char.dy*timeDiff + timeDiff*gravity;				if (verticalChange > 15.0) verticalChange = 15.0;				char.dy += timeDiff*gravity;			}						// react to changes from key presses			var horizontalChange = 0;			var newAnimState:String = "stand";			var newDirection:int = char.direction;						if (char.moveLeft) {				// walk left				horizontalChange = -char.walkSpeed*timeDiff;				newAnimState = "walk";				newDirection = -1;				if (char.isSprinting) { 					horizontalChange = -sprintSpeed*timeDiff;				} 			} else if (char.moveRight) {				// walk right				horizontalChange = char.walkSpeed*timeDiff;				newAnimState = "walk";				newDirection = 1;				if (char.isSprinting) {					horizontalChange = sprintSpeed*timeDiff;				}			}						if (char.jump) {				// start jump				char.jump = false;				char.dy = -char.jumpSpeed;				verticalChange = -char.jumpSpeed;				newAnimState = "jump";			} 					// assume no wall hit, and hanging in air			char.hitWallRight = false;			char.hitWallLeft = false;			char.inAir = true;						// find new vertical position			var newY:Number = char.mc.y + verticalChange;								// loop through all fixed objects to see if character has landed			for(var i:int=0;i<fixedObjects.length;i++) {				// If character is not on ladder then he can't pass through the bottom of the blocks				if (!char.onLadder) {					// check to see if character is standing between the left and right side of the object					if ((char.mc.x+char.width/2 > fixedObjects[i].leftside) && (char.mc.x-char.width/2 < fixedObjects[i].rightside)) {						// Stop character from jumping through the bottom of the object						if ((char.mc.y - char.height >= fixedObjects[i].bottomside) && (newY - char.height < fixedObjects[i].bottomside)) {							newY = fixedObjects[i].bottomside + char.height;							char.dy = 1;							char.inAir = true;						// Stop character from falling through the floor						} else if ((char.mc.y <= fixedObjects[i].topside) && (newY > fixedObjects[i].topside)) {								newY = fixedObjects[i].topside;								char.dy = 0;								char.inAir = false;								break;							}					}				// if character is on ladder then he may pass up through the bottom of the block				} else if (char.onLadder) {					// Without the code below the character is able to pass through the top of the block at the top of the ladder					// However, the character will continue to pass through the bottom block at the base of the ladder if the user doesn't move either left or right to get off the ladder										/*if ((char.mc.x+char.width/2 > fixedObjects[i].leftside) && (char.mc.x-char.width/2 < fixedObjects[i].rightside)) {						if ((char.mc.y <= fixedObjects[i].topside) && (newY > fixedObjects[i].topside)) {							newY = fixedObjects[i].topside;							char.dy = 0;							char.inAir = false;							break;									} 					}*/					break;				} 			}									// find new horizontal position			var newX:Number = char.mc.x + horizontalChange;								// Climbing the ladder			if (char.canClimb && !char.jump) {				// if Up key pressed - Climb up				if (char.climbUp) {					char.onLadder = true;					char.dy = -char.climbSpeed*timeDiff;				// if Down key pressed - Climb down				} else if (char.climbDown) {					char.onLadder = true;					char.dy = char.climbSpeed*timeDiff;				// if no longer colliding the hero is no longer on the ladder				} else if (!char.canClimb) {					char.onLadder = false;				// Prevents char from moving continuously upward or downward 				} else if (!char.climbUp) {					char.dy = 0;					char.onLadder = true;				} 											}								// loop through all objects to see if character has bumped into a wall			for(i=0;i<fixedObjects.length;i++) {				if ((newY > fixedObjects[i].topside) && (newY-char.height < fixedObjects[i].bottomside)) {					if ((char.mc.x-char.width/2 >= fixedObjects[i].rightside) && (newX-char.width/2 <= fixedObjects[i].rightside)) {						newX = fixedObjects[i].rightside+char.width/2;						char.hitWallLeft = true;						break;					}					if ((char.mc.x+char.width/2 <= fixedObjects[i].leftside) && (newX+char.width/2 >= fixedObjects[i].leftside)) {						newX = fixedObjects[i].leftside-char.width/2;						char.hitWallRight = true;						break;					}				}			}									// set position of character			char.mc.x = newX;			char.mc.y = newY;						// set animation state			if (char.inAir) {				newAnimState = "jump";			}			char.animstate = newAnimState;						// move along walk cycle			if (char.animstate == "walk") {				char.animstep += timeDiff/60;				if (char.animstep > char.walkAnimation.length) {					char.animstep = 0;				}				char.mc.gotoAndStop(char.walkAnimation[Math.floor(char.animstep)]);							// not walking, show stand or jump state			} else {				char.mc.gotoAndStop(char.animstate);			}						// changed directions			if (newDirection != char.direction) {				char.direction = newDirection;				char.mc.scaleX = char.direction;			}		}								// scroll to the right or left if needed		public function scrollWithHero() {			var stagePosition:Number = gamelevel.x+hero.mc.x;			var rightEdge:Number = stage.stageWidth-edgeDistance;			var leftEdge:Number = edgeDistance;			if (stagePosition > rightEdge) {				gamelevel.x -= (stagePosition-rightEdge);				if (gamelevel.x < -(gamelevel.width-stage.stageWidth)) gamelevel.x = -(gamelevel.width-stage.stageWidth);			}			if (stagePosition < leftEdge) {				gamelevel.x += (leftEdge-stagePosition);				if (gamelevel.x > 0) gamelevel.x = 0;			}		}				// check collisions with enemies, items		public function checkCollisions() {						// enemies			for(var i:int=enemies.length-1;i>=0;i--) {				if (hero.mc.hitTestObject(enemies[i].mc)) {										// is the hero jumping down onto the enemy?					if (hero.inAir && (hero.dy > 0)) {						enemyDie(i);					} else {						heroDie();					}				}			}						// items			for(i=otherObjects.length-1;i>=0;i--) {				if (hero.mc.hitTestObject(otherObjects[i])) {					getObject(i);				}			}			for(i=ladderObjects.length-1;i>=0;i--) {				if (hero.mc.hitTestObject(ladderObjects[i])) {					climbLadder(i);					/*hero.canClimb = true;					hero.jump = false;					if (hero.climbUp || hero.climbDown) {						hero.mc.x = ladderObjects[i].x;*/					//}									} else {					hero.canClimb = false;					hero.onLadder = false;				}			}			/*for(i=0;i<ladderTopOb.length;i++) {				if(hero.mc.hitTestObject(ladderTopOb[i])) {					hero.ladderTop = true;					trace("On top of ladder: "+hero.ladderTop);				}			}*/						//for(i=la					}				public function climbLadder(ladderNum:int) {						if (ladderObjects[ladderNum] is Ladder) {				hero.canClimb = true;				hero.jump = false;				if (hero.climbUp || hero.climbDown) {					hero.mc.x = ladderObjects[ladderNum].x				}			}				}				// remove enemy		public function enemyDie(enemyNum:int) {			var pb:PointBurst = new PointBurst(gamelevel,"Got Em!",enemies[enemyNum].mc.x,enemies[enemyNum].mc.y-20);			gamelevel.removeChild(enemies[enemyNum].mc);			enemies.splice(enemyNum,1);		}				// enemy got player		public function heroDie() {			// show dialog box			var dialog:Dialog = new Dialog();			dialog.x = 175;			dialog.y = 100;			addChild(dialog);					if (playerLives == 0) {				gameMode = "gameover";				dialog.message.text = "Game Over!";			} else {				gameMode = "dead";				dialog.message.text = "He Got You!";				playerLives--;			}						hero.mc.gotoAndPlay("die");		}				// player collides with objects		public function getObject(objectNum:int) {			// award points for treasure			if (otherObjects[objectNum] is Treasure) {				var pb:PointBurst = new PointBurst(gamelevel,100,otherObjects[objectNum].x,otherObjects[objectNum].y);				gamelevel.removeChild(otherObjects[objectNum]);				otherObjects.splice(objectNum,1);				addScore(100);							// got the key, add to inventory			} else if (otherObjects[objectNum] is Key) {				pb = new PointBurst(gamelevel,"Got Key!" ,otherObjects[objectNum].x,otherObjects[objectNum].y);				playerObjects.push("Key");				gamelevel.removeChild(otherObjects[objectNum]);				otherObjects.splice(objectNum,1);							// hit the door, end level if hero has the key			} else if (otherObjects[objectNum] is Door) {				if (playerObjects.indexOf("Key") == -1) return;				if (otherObjects[objectNum].currentFrame == 1) {					otherObjects[objectNum].gotoAndPlay("opening");					levelComplete();				}							// got the chest, game won			} else if (otherObjects[objectNum] is Chest) {				otherObjects[objectNum].gotoAndStop("open");				gameComplete();			}							}				// add points to score		public function addScore(numPoints:int) {			gameScore += numPoints;			scoreDisplay.text = String(gameScore);		}				// update player lives		public function showLives() {			livesDisplay.text = String(playerLives);		}				// level over, bring up dialog		public function levelComplete() {			gameMode = "done";			var dialog:Dialog = new Dialog();			dialog.x = 175;			dialog.y = 100;			addChild(dialog);			dialog.message.text = "Level Complete!";		}				// game over, bring up dialog		public function gameComplete() {			gameMode = "gameover";			var dialog:Dialog = new Dialog();			dialog.x = 175;			dialog.y = 100;			addChild(dialog);			dialog.message.text = "You Got the Treasure!";		}				// dialog button clicked		public function clickDialogButton(event:MouseEvent) {			removeChild(MovieClip(event.currentTarget.parent));						// new life, restart, or go to next level			if (gameMode == "dead") {				// reset hero				showLives();				hero.mc.x = hero.startx;				hero.mc.y = hero.starty;				gameMode = "play";			} else if (gameMode == "gameover") {				cleanUp();				gotoAndStop("start");			} else if (gameMode == "done") {				cleanUp();				nextFrame();			}						// give stage back the keyboard focus			stage.focus = stage;		}							// clean up game		public function cleanUp() {			removeChild(gamelevel);			this.removeEventListener(Event.ENTER_FRAME,gameLoop);			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpFunction);		}			}	}