package com.jiangma.server;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.jiangma.server.mapper")
public class JiangMaApplication {

    public static void main(String[] args) {
        SpringApplication.run(JiangMaApplication.class, args);
    }
}
