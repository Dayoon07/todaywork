<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>채팅 화면</title>
	<style>
		#packet:hover {
			background-color: black;
			color: white;
			cursor: pointer;
		}
		#messageContainer {
			width: 450px;
			height: 650px;
			overflow-y: scroll;
			border: 1px solid black;
		}
		.msg-font {
			font-size: 20px;
			font-weight: bolder;
		}
		.my-msg {
			text-align: right;	
		}
		.other-msg {
			text-align: left;	
		}
		#userList {
			width: 200px;
			height: 650px;
			border: 1px solid black;
			overflow-y: scroll;
		}
	</style>
</head>
<body>
	<h2>채팅 연습하기</h2>
	
	<div style="display: flex; width: auto; height: 35px;">
		<input type="text" id="userid">
		<input type="hidden" id="receiver">
		<button onclick="openChatting();">채팅 입장</button>
	</div>
	
	<div style="display: flex">
		<div id="messageContainer">
		
		</div>
		<div>
			<div id="userList">
				<h3>현재 접속자</h3>
			</div>
		</div>
	</div>
	
	<div style="display: flex; justify-content: start; align-items: center;">
		<textarea rows="2" cols="55" id="sendMessage" style="resize: none;"></textarea>
		<button style="padding: 7.5px;" id="packet">전송</button>
	</div>
	
	<script>
		let websocket;
		const openChatting = () => {
			// websocket 연결을 하려면 js가 제공하는 WebSocket 객체를 생성한다.
			// 파라미터에 서버매핑주소를 전달
			// ws://서버ip주소:포트번호/contextPath/매핑주소  ->
			// wss://서버ip주소:포트번호/contextPath/매핑주소 ->
			websocket = new WebSocket("ws://localhost:9090/websocket/chating");
			
			// 서버와 통신할 수 있는 핸들러를 등록
			websocket.onopen = (data) => {
				console.log(data);
				const userid = document.querySelector("#userid").value;
				const msg = new Message("enter", userid, '', '');
				
				// js 객체를 문자열로 변경해주는 함수 => JSON.stringify();
				websocket.send(JSON.stringify(msg));
				document.querySelector("#userid").readOnly = true;
				document.querySelector("#userid").style.backgroundColor = "lightgray";
			}
			websocket.onmessage = (msg) => {
				const message = JSON.parse(msg.data);
				/* console.log(message);
				console.log(msg.data); */
				switch (message.type) {
					case "enter" : appendMessage(message); break;
					case "msg" : printMessage(message); break;
					case "userList" : printUser(message.data); break;
				}
			}
		}
		
		function appendMessage(message) {
			const $container = document.getElementById("messageContainer");
			const $h4 = document.createElement("h4");
			$h4.innerText = message.data;
			$h4.style.textAlign = "center";
			$container.appendChild($h4);
			
			/* const $List = document.getElementById("userList");
			const $user = document.createElement("div");
			$user.innerText = message.data;
			$user.style.textAlign = "left";
			$List.appendChild($user); */
		}
		
		function printUser(list) {
			const members = JSON.parse(list);
			console.log(members);
			
			/* const ul = members.reduce((prev, next) => prev + `<li>\${ next }</li>`, `</ul>`) + "</ul>";
			console.log(ul);
			document.getElementById("userList").innerHTML = ul; */
			
			const $ul = document.createElement("ul");
			members.forEach(e => {
				const $li = document.createElement("li");
				$li.innerText = e;
				$li.addEventListener("click", () => {
					[...(e.target.parentElement.children)].forEach(e => {
						e.style.background = "white";
					});
					e.target.style.background = "skyblue";
					document.querySelector("#receiver").value = e.target.innerText;
				});
				$ul.appendChild($li);
			});
			document.getElementById("userList").innerHTML = "";
			document.getElementById("userList").appendChild($ul);
		}
		
		function printMessage(message) {
			const $messageBox = document.createElement("div");
			const $send = document.createElement("span");
			$send.innerText = message.sender;
			$messageBox.appendChild($send);
			
			const $msg = document.createElement("p");
			$msg.classList.add("msg-font");
			$messageBox.classList.add(document.querySelector("#userid").value == message.sender ? "my-msg" : "other-msg");
			$msg.innerText = message.data;
			$messageBox.appendChild($msg);
			
			document.querySelector("#messageContainer").appendChild($messageBox);
		}
		
		document.querySelector("#packet").addEventListener("click", e => {
			const $textarea = document.querySelector("#sendMessage");
			const msg = $textarea.value;
			const userid = document.querySelector("#userid").value;
			
			const receiver = document.querySelector("#receiver").value;
			
			const sendData = new Message('msg', userid, '', msg);
			websocket.send(JSON.stringify(sendData));
		});
		
		class Message {
			constructor(type, sender, receiver, data) {
				this.type = type;
				this.sender = sender;
				this.receiver = receiver;
				this.data = data;
			}
		}
			
		
		
	</script>
</body>
</html>