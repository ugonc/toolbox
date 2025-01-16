package com.example.client_assertion_generator;

import java.security.KeyFactory;
import java.security.interfaces.RSAPrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Base64;
import java.util.Date;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;

import lombok.extern.slf4j.Slf4j;

@SpringBootApplication
@Slf4j
public class ClientAssertionGeneratorApplication implements CommandLineRunner {

	public static void main(String[] args) {
		SpringApplication.run(ClientAssertionGeneratorApplication.class, args);
	}

	@Override
	public void run(String... args) throws Exception {
		log.info("Client Assertion Generator started");

		String issuer = args[0];
		String audience = args[1];
		String privateKey = args[2];

		byte[] decoded = Base64.getDecoder().decode(privateKey);
		KeyFactory keyFactory = KeyFactory.getInstance("RSA");
		PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(decoded);
		RSAPrivateKey rsaPrivateKey = (RSAPrivateKey) keyFactory.generatePrivate(keySpec);

		Algorithm algorithm = Algorithm.RSA256(null, rsaPrivateKey);

		Date expiresAt = Date.from(ZonedDateTime.now(ZoneId.systemDefault()).plusMinutes(60).toInstant());

		String clientAssertion = JWT.create()
			.withIssuer(issuer)
			.withAudience(audience)
			.withSubject(issuer)
			.withExpiresAt(expiresAt) 
			.sign(algorithm);

		log.info("Client Assertion: {}", clientAssertion);
	}
}
