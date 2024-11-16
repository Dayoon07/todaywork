package com.km.config;

import java.util.HashMap;
import java.util.Map;

import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.km.model.dto.Message;

public class ChattingServer extends TextWebSocketHandler {
	
	ObjectMapper mapper = new ObjectMapper();
	
	private Map<String, WebSocketSession> clients = new HashMap<>();
	
	// 자정된 메서드를 재정의해서 사용

	@Override
	public void afterConnectionEstablished(WebSocketSession session) throws Exception {
		// websocket 연결이 되면 실행되는 메서드
		// js에서 new WebSocket("주소"); <- 실행하면 됨
//		super.afterConnectionEstablished(session);
		System.out.println("클라이언트 접속! " + session.getId() + "가 접속함");
	}

	@Override
	protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
		System.out.println("클라이언트가 보낸 메시지 : " + message.getPayload());
		Message msg = mapper.readValue(message.getPayload(), Message.class);
		System.out.println(msg);
		switch (msg.getType()) {
			case "enter" : addClient(session, msg); break;
			case "msg" : sendMessage(session, msg); break;
		}
	}
	
	private void addClient(WebSocketSession session, Message message) {
		clients.put(message.getSender(), session);
		message.setData(message.getSender() + "님이 입장하셨습니다.");
		broadcastSend(message);
	}
	
	private void sendMessage(WebSocketSession sessionm, Message message) {
		if (message.getReceiver() == null || message.getReceiver().equals("")) {
			broadcastSend(message);
		} else {
			
		}
	}
	
	private void broadcastSend(Message message) {
		clients.values().stream().forEach(n -> {
			try {
				TextMessage sendMsg = new TextMessage(mapper.writeValueAsString(message));
				n.sendMessage(sendMsg);
			} catch (Exception e) {
				e.printStackTrace();
			}
		});
	}
	
	@Override
	public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
		super.afterConnectionClosed(session, status);
	}
	
}
