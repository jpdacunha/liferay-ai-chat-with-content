package com.github.qls.ai.chatbot.backend;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.core.env.Environment;

import com.liferay.client.extension.util.spring.boot.ClientExtensionUtilSpringBootComponentScan;

@Import(ClientExtensionUtilSpringBootComponentScan.class)
@SpringBootApplication
public class AiChatbotApplication {

	private static final Log _log = LogFactory.getLog(AiChatbotApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(AiChatbotApplication.class, args);
	}

	@Bean
	ApplicationRunner logResolvedConfiguration(
		Environment environment,
		@Value("${assistant.api.cors.allowed-origins:}") String allowedOrigins,
		@Value("${liferay.oauth.urls.excludes:}") String oauthExcludedUrls,
		@Value("${server.port:}") String serverPort) {

		return args -> {
			String[] appliedProfiles = environment.getActiveProfiles();

			if (appliedProfiles.length == 0) {
				appliedProfiles = environment.getDefaultProfiles();
			}

			String appliedProfilesLog = String.join(",", appliedProfiles);

			_log.info("Spring Boot profile(s) applied: " + appliedProfilesLog);

			_log.info(String.format(
				"CORS Resolved configuration -> activeProfiles=%s, server.port=%s, assistant.api.cors.allowed-origins=%s, liferay.oauth.urls.excludes=%s",
				appliedProfilesLog,
				serverPort,
				allowedOrigins,
				oauthExcludedUrls));
		};
	}
}
