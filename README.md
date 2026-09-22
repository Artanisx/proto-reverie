# Proto Reverie
This is a [Godot](https://godotengine.org/) prototype 3D Game for a procedurally generated FPS dungeon crawler.

![Proto Reverie Gameplay 1](/images/gameplay1.png)
![Proto Reverie Gameplay 2](/images/gameplay2.png)
![Proto Reverie Gameplay 3](/images/gameplay3.png)
![Proto Reverie Map](/images/map.png)
![Proto Reverie Gameplay 4](/images/gameplay4.png)
![Proto Reverie Acid Pool](/images/acid_pool.png)
![Proto Reverie Acid Pool 2](/images/acid_pool_2.png)
![Proto Reverie Acid Pool 3](/images/acid_pool_3.png)
![Proto Reverie Gameplay 5](/images/gameplay5.png)
![Proto Reverie Gameplay 6](/images/gameplay6.png)
![Proto Reverie Gameplay 7](/images/gameplay7.png)
![Proto Reverie Gameplay 8](/images/gameplay8.png)

## Overview
Proto Reverie is a procedurally generated dungeon crawler. The map is generated from scratch at each new playthrough; the dungeon contains rooms that can be of any kind (15 manually crafted rooms), populated with a random number of enemies and pickups.
The dungeon can also feature locked doors that lead to special bonus room. Each dungeon may feature a number of these special rooms, and the locked doors have a frame of the color of the key that needs to be used to open said door. For each locked room, a random room is selected and killing all enemies from that room will drop the key. The game is completed once you reach the end room which contains a boss. Killing the boss will result in your victory.
The game also features a levelling system, the more enemies you kill and the more experience coins you pickup, the more levels you'll gain. Each level increases not only the maximum health, but also the power of your weapon; specifically that will improve the rate of fire and damage of the gun. Ammo can also be found picking up the coins. At level 3, 6 and 9 you will also gain a Shield that can be used to block attacks! Each attack blocked will damage the shield and it will drop on the ground once broken.

## Goal of the game
This main goal of the game is to explore the dungeon, level up to become stronger and finally find and kill the end boss. Each run will be different, and if you complete the game you can also restart the run with a bigger dungeon which will make the game more challenging to complete!

# Power Ups
You can find three pickables:

**Experience Coin**
![Exp Coin](/images/exp_coin.png)
Experience coin will increase your experience and restock some of your ammunitions.

**Health Pack**
![Health Pack](/images/health_pack.png)
Health Pack will heal you. You can pick one up only if you are wounded.

**Keys**
![Purple Key](/images/key.png)
Killing all enemies of a special room, can have the last of them drop a key. There are four colored keys that opens doors of the same color. Each locked room is filled with big experience coins and a big health pack!

#UI
![Proto Reverie Gameplay 8](/images/ui_screen.png)
1 - Your health bar. It will change color to reflect your status with green being healthy, yellow being wounded and red being critically wounded.
2 - Your experience bar. If you fill it up, you'll gain a level. Each level provides more health, incrases your power and awards a shield at level 3, 6 and 9.
3 - Your level is shown here. Level cap is 10.
4 - Your power is shown here. Each point grants more damage for your weapon and increases the rate of fire.
5 - Your minimap. You can see your position in yellow and your cone of view. Enemies are shown as red dots, experience coin as small yellow dots. A big red circle signify a bonus room, whereas a big blue circle signifies the end room where the boss is.
6 - Your ammunition bar. If you reach zero you cannot shoot! Find an experience coin as that will replenish your ammo.
7 - Your shield condition bar. If you have a shield equipped, you'll see its condition here. Each block will damage it, and you'll drop the broken shield if the bar reaches 0.
8 - Your keys are displayed here.


## Controls
The game is mainly controlled with the mouse and your keyboard. 

**WASD** to move around as any FPS.

**SPACE BAR** to jump.

**Mouse: Left Click** to shoot with your gun. You can press quickly to shoot more often, up to the rate of fire of the weapon.

**Mouse: Right Click** to block with your shield if you have one equipped.

**F** is the action button. It will allow you to kick a closeby enemy to stun them, or to open a door. shoot with your gun. You can press quickly to shoot more often, up to the rate of fire of the weapon.

**PAGE UP** will open the Map. You can still move around while the map is open and the game is not paused, so be careful!

**PAGE DOWN** will close the Map.

**Shift** Hold it to run.

**ESC** or **Q** to quit the game.

**R** will let you restart the game if you die and are in the game over screen.

**H** will let you restart the game at an harder difficulty and bigger dungeon if you complete the game killing the final boss.

# Credits
Pixel Art done by me using a self compiled [Aseprite](https://www.aseprite.org/).<br>
3D Art done by me using [Blender](https://www.blender.org/).<br>
Most of the graphics are done manually by me under the guidance of [this tutorial series](https://www.youtube.com/playlist?list=PLT26e2jOwbdg) from [The Gamedev Tavern](https://www.youtube.com/@GameDevTavern), however, this prototype also features art done entirely by myself with no guidance (for better or worse).<br>
Font [Another Tiny Pixel Font](https://alasseearfalas.itch.io/another-tiny-pixel-font-mono-3x5).<br>
Music done by [Miles Lacey](https://mileslaceysound.com/) shared by [The Gamedev Tavern](https://www.youtube.com/@GameDevTavern).<br>


# Software
Below the list of all software I used to develop this game.

[Godot Engine](https://godotengine.org/)

[Github Desktop](https://github.com/apps/desktop)

[Aseprite](https://www.aseprite.org/)

[Blender](https://www.blender.org/)

[Notepad++](https://notepad-plus-plus.org/)