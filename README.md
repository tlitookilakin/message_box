# Godot MessageBox Plugin
By Tlitookilakin, Built for Godot 3.2

## Overview
MessageBox is a plugin for Godot that adds a new Message Box node type to display rich text with a typewriter effect.

## Features
* Full BBCode Support, including custom effects
* Change speed dynamically with BBCode
* Automatic scrolling for oversized text
* Can play forwards and in reverse
* Allows skip-completion and text acceleration
* Plays sounds as text is typed
* Automatically plays when message is changed!

## Usage

### BBCode
Supports all BBCode features of RichTextLabel. To change the text, just set the Message variable of the MessageBox. Custom effects can be added either by using `install_effect` or assigning them in the Inspector further down.

### Speed changing
You can set the base speed for the MessageBox by simply setting its `speed` property, either through code or the inspector. If positive, will play forwards. If negative, will play backwards. If zero, will instantly display the entire text without animation.

To change with bbcode, use `This is 1x speed. [spd =3]This is 3x speed[/spd]`. This is a speed multiplier for the base speed, and must be greater than 0. Unfortunately, due to the limitations of bbcode, it is not possible to nest speed changes and they must be done in sequence.

The `acceleration` property of a messagebox is also a multiplier, and must also be greater than 0. This multiplier is only applied while the `accelerate_action` is held.

### Sounds
For flexibility reasons, MessageBox is designed to use an external audio player, rather than an integrated one. You can assign a player by setting `player` to the nodepath of the desired audio player, either through the inspector or code.

The MessageBox will play random sounds from a selection. To set the sound(s) to play, either add them to the `voice` array in the inspector or set `voice` to an array of audiostreams you want the MessageBox to pick from. If you want it to use the same audio every time, just make it an array with a single entry.

If a player is not provided or does not exist, or `voice` is empty, no sound will play.

### Notes
While I've done my best to make sure that it runs fast and smooth, RichTextLabel in general and MessageBox specifically have a lot of overhead, and I would recommend avoiding using a lot of these in any given scene, as it may impact performance.

In theory, MessageBox supports most of the features of RichTextLabel, however using some features may cause instability and unexpected behavior. Generally, anything modifying the text or bbcode directly should be avoided, and setting `scroll_following` to true will break the automatic scrolling. (automatic scrolling uses a custom implementation due to [a known bug](https://github.com/godotengine/godot/issues/37720). When this is fixed, the custom implementation will likely be removed.)
