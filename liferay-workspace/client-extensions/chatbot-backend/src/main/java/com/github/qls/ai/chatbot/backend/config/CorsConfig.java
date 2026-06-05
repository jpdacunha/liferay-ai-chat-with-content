package com.github.qls.ai.chatbot.backend.config;

import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

	@Value("${assistant.api.cors.allowed-origins:http://localhost:8080,http://127.0.0.1:8080,http://localhost:3000,http://127.0.0.1:3000}")
	private String[] allowedOrigins = new String[0];

	@Override
	public void addCorsMappings(@NonNull CorsRegistry registry) {
		registry.addMapping("/assistant/api/**")
			.allowedOrigins(Objects.requireNonNull(allowedOrigins))
			.allowedMethods("POST", "OPTIONS")
			.allowedHeaders("*")
			.allowCredentials(true)
			.maxAge(3600);
	}
}