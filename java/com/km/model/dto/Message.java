package com.km.model.dto;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Message {
	private String type;
	private String sender;
	private String receiver;
	private String data;
}
