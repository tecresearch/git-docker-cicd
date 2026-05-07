package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {

    @GetMapping("/api/greeting")
    public String greeting() {
        return "Hello, World!";
    }

    // Updated - First production deployment
    // This demonstrates the complete end-to-end CI/CD pipeline

}

