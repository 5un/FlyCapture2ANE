﻿/*
*
* Copyright (c) 2008-2010 Lu Aye Oo
*
* @author 		Lu Aye Oo
*
* http://code.google.com/p/flash-console/
*
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*
*/
package com.junkbyte.console.core
{
	import com.junkbyte.console.Console;
	import com.junkbyte.console.ConsoleLevel;

	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	[Event(name = "connect", type = "flash.events.Event")]
	/**
	 * @private
	 */
	public class Remoting extends ConsoleCore
	{

		protected var _callbacks:Object = new Object();
		protected var _remoting:Boolean;
		protected var _local:LocalConnection;
		protected var _socket:Socket;
		protected var _sendBuffer:ByteArray = new ByteArray();
		protected var _recBuffers:Object = new Object();
		protected var _senders:Dictionary = new Dictionary();

		protected var _loggedIn:Boolean;

		protected var _selfId:String;
		protected var _lastRecieverId:String;

		public function Remoting(m:Console)
		{
			super(m);
			registerCallback("login", function(bytes:ByteArray):void {
				login(bytes.readUTF());
			});
		}

		public function update():void
		{
			if (_sendBuffer.length)
			{
				if (_socket && _socket.connected)
				{
					_socket.writeBytes(_sendBuffer);
					//_socket.flush();
					_sendBuffer = new ByteArray();
				}
				else if (_local)
				{
					var packet:ByteArray;
					_sendBuffer.position = 0;
					if (_sendBuffer.bytesAvailable < 38000)
					{
						packet = _sendBuffer;
						_sendBuffer = new ByteArray();
					}
					else
					{
						packet = new ByteArray();
						_sendBuffer.readBytes(packet, 0, Math.min(38000, _sendBuffer.bytesAvailable));
						var newbuffer:ByteArray = new ByteArray();
						_sendBuffer.readBytes(newbuffer);
						_sendBuffer = newbuffer;
					}
					_local.send(remoteLocalConnectionName, "synchronize", _selfId, packet);
				}
				else
				{
					_sendBuffer = new ByteArray();
				}
			}
			for (var id:String in _recBuffers)
			{
				processRecBuffer(id);
			}
		}

		protected function get selfLlocalConnectionName():String
		{
			return config.remotingConnectionName + "Sender";
		}

		protected function get remoteLocalConnectionName():String
		{
			return config.remotingConnectionName + "Receiver";
		}

		private function processRecBuffer(id:String):void
		{
			if (!_senders[id])
			{
				_senders[id] = true;
				if (_lastRecieverId)
				{
					report("Switched to [" + id + "] as primary remote.", -2);
				}
				_lastRecieverId = id;
			}

			var buffer:ByteArray = _recBuffers[id];
			try
			{
				var pointer:uint = buffer.position = 0;
				while (buffer.bytesAvailable)
				{
					var cmdlen:uint = buffer.readByte();
					if (buffer.bytesAvailable == 0)
					{
						break;
					}
					var cmd:String = buffer.readUTFBytes(cmdlen);
					var arg:ByteArray = null;
					if (buffer.bytesAvailable == 0)
					{
						break;
					}
					if (buffer.readBoolean())
					{
						if (buffer.bytesAvailable == 0)
						{
							break;
						}
						var blen:uint = buffer.readUnsignedInt();
						if (buffer.bytesAvailable < blen)
						{
							break;
						}
						arg = new ByteArray();
						buffer.readBytes(arg, 0, blen);
					}
					var callbackData:Object = _callbacks[cmd];
					if (callbackData == null)
					{
						report("Unknown remote commmand received [" + cmd + "].", ConsoleLevel.ERROR);
					}
					else if (!callbackData.latest || id == _lastRecieverId)
					{
						if (arg)
						{
							callbackData.fun(arg);
						}
						else
						{
							callbackData.fun();
						}
					}
					pointer = buffer.position;
				}
				if (pointer < buffer.length)
				{
					var recbuffer:ByteArray = new ByteArray();
					recbuffer.writeBytes(buffer, pointer);
					_recBuffers[id] = buffer = recbuffer;
				}
				else
				{
					delete _recBuffers[id];
				}
			}
			catch (err:Error)
			{
				report("Remoting sync error: " + err, 9);
			}
		}

		private function synchronize(id:String, obj:Object):void
		{
			var packet:ByteArray = obj as ByteArray;
			if (packet == null)
			{
				report("Remoting sync error. Recieved non-ByteArray:" + obj, 9);
				return;
			}
			var buffer:ByteArray = _recBuffers[id];
			if (buffer)
			{
				buffer.position = buffer.length;
				buffer.writeBytes(packet);
			}
			else
			{
				_recBuffers[id] = packet;
			}
		}

		public function send(command:String, arg:ByteArray = null):Boolean
		{
			if (!_remoting)
			{
				return false;
			}
			_sendBuffer.position = _sendBuffer.length;
			_sendBuffer.writeByte(command.length);
			_sendBuffer.writeUTFBytes(command);
			if (arg)
			{
				_sendBuffer.writeBoolean(true);
				_sendBuffer.writeUnsignedInt(arg.length);
				_sendBuffer.writeBytes(arg);
			}
			else
			{
				_sendBuffer.writeBoolean(false);
			}
			return true;
		}

		public function get connected():Boolean
		{
			return _remoting && _loggedIn;
		}

		public function get remoting():Boolean
		{
			return _remoting;
		}

		public function set remoting(newMode:Boolean):void
		{
			if (newMode == _remoting)
			{
				return;
			}
			_selfId = generateId();
			if (newMode)
			{
				startRemoting();
			}
			else
			{
				close();
			}
			console.panels.updateMenu();
		}

		protected function startRemoting():void
		{
			if (!startLocalConnection())
			{
				report("Could not create remoting client service.", 10);
				return;
			}
			_sendBuffer = new ByteArray();
			report("<b>Remoting started.</b> " + getInfo(), -1);
			send("started");
		}

		public function remotingSocket(host:String, port:int = 0):void
		{
			if (_socket && _socket.connected)
			{
				_socket.close();
				_socket = null;
			}
			if (host && port)
			{
				remoting = true;
				report("Connecting to socket " + host + ":" + port);
				_socket = new Socket();
				_socket.addEventListener(Event.CLOSE, socketCloseHandler);
				_socket.addEventListener(Event.CONNECT, socketConnectHandler);
				_socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler);
				_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketSecurityErrorHandler);
				_socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
				_socket.connect(host, port);
			}
		}

		private function socketCloseHandler(e:Event):void
		{
			if (e.currentTarget == _socket)
			{
				_socket = null;
			}
		}

		private function socketConnectHandler(e:Event):void
		{
			report("Remoting socket connected.", -1);
			_sendBuffer = new ByteArray();
			if (_loggedIn || checkLogin(""))
			{
				sendLoginSuccess();
			}
			else
			{
				send("loginRequest");
			}
		}

		private function socketIOErrorHandler(e:Event):void
		{
			report("Remoting socket error." + e, 9);
			remotingSocket(null);
		}

		private function socketSecurityErrorHandler(e:Event):void
		{
			report("Remoting security error." + e, 9);
			remotingSocket(null);
		}

		private function socketDataHandler(e:Event):void
		{
			handleSocket(e.currentTarget as Socket);
		}

		public function handleSocket(socket:Socket):void
		{
			if (!_senders[socket])
			{
				_senders[socket] = generateId();
				_socket = socket;
			}
			var bytes:ByteArray = new ByteArray();
			socket.readBytes(bytes);
			synchronize(_senders[socket], bytes);
		}

		protected function onLocalConnectionStatus(e:StatusEvent):void
		{
			if (e.level == "error" && _loggedIn && !(_socket && _socket.connected))
			{
				report("Remote connection lost.", ConsoleLevel.ERROR);
				_loggedIn = false;
			}
		}

		protected function onRemoteAsyncError(e:AsyncErrorEvent):void
		{
			report("Problem with remote sync. [<a href='event:remote'>Click here</a>] to restart.", 10);
			remoting = false;
		}

		protected function onRemotingSecurityError(e:SecurityErrorEvent):void
		{
			report("Remoting security error.", 9);
			printHowToGlobalSetting();
		}

		protected function getInfo():String
		{
			return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
		}

		protected function printHowToGlobalSetting():void
		{
			report("Make sure your flash file is 'trusted' in Global Security Settings.", -2);
			report("Go to Settings Manager [<a href='event:settings'>click here</a>] &gt; 'Global Security Settings Panel'  &gt; add the location of the local flash (swf) file.", -2);
		}

		protected function generateId():String
		{
			return new Date().time + "." + Math.floor(Math.random() * 100000);
		}

		protected function startLocalConnection():Boolean
		{
			close();
			_remoting = true;
			_local = new LocalConnection();
			_local.client = {synchronize: synchronize};
			if (config.allowedRemoteDomain)
			{
				_local.allowDomain(config.allowedRemoteDomain);
				_local.allowInsecureDomain(config.allowedRemoteDomain);
			}
			_local.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRemotingSecurityError, false, 0, true);
			_local.addEventListener(StatusEvent.STATUS, onLocalConnectionStatus, false, 0, true);
			_local.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onRemoteAsyncError, false, 0, true);

			try
			{
				_local.connect(selfLlocalConnectionName);
			}
			catch (err:Error)
			{
				_remoting = false;
				_local = null;
				return false;
			}
			return true;
		}

		public function registerCallback(key:String, fun:Function, lastestSenderOnly:Boolean = false):void
		{
			_callbacks[key] = {fun: fun, latest: lastestSenderOnly};
		}

		private function sendLoginSuccess():void
		{
			_loggedIn = true;
			send("loginSuccess");
			dispatchEvent(new Event(Event.CONNECT));
		}

		public function login(pass:String = ""):void
		{
			if (_loggedIn || checkLogin(pass))
			{
				sendLoginSuccess();
			}
			else
			{
				send("loginFail");
			}
		}

		private function checkLogin(pass:String):Boolean
		{
			return ((config.remotingPassword === null && config.keystrokePassword == pass)
				|| config.remotingPassword === ""
				|| config.remotingPassword == pass
				);
		}

		public function close():void
		{
			if (_local)
			{
				try
				{
					_local.close();
				}
				catch (error:Error)
				{
					report("Remote.close: " + error, 10);
				}
			}
			_remoting = false;
			_sendBuffer = new ByteArray();
			_local = null;
		}
	}
}
