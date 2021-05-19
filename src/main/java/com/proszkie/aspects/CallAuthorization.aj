package com.proszkie.aspects;

import com.proszkie.telecom.Customer;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public aspect CallAuthorization {

    private static final Map<String, String> credentials = new HashMap<>();
    private static final File credentialsFile = new File("/tmp/zmwo-credentials.txt");
    private String password;

    static {
        loadCredentials();
    }

    private static void loadCredentials() {
        if (!credentialsFile.exists()) {
            throw new IllegalStateException("Credentials file was not found");
        }
        try {
            Files.readAllLines(credentialsFile.toPath())
                    .stream()
                    .map(line -> line.split(":"))
                    .forEach(splitted -> credentials.put(splitted[0], splitted[1]));
        } catch (IOException e) {
            throw new IllegalStateException("Credentials file has been corrupted");
        }
    }

    pointcut customerCall(Customer caller): this(caller) && execution(* com.proszkie.telecom.Customer.call(..));

    before(Customer caller): customerCall(caller) {
        System.out.println("Password for " + caller + " required: ");
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            password = br.readLine();
        } catch (IOException e) {
            System.out.println("Error occured during reading the password");
        }
    }

    Object around(Customer caller): customerCall(caller) {
        if (credentials.containsKey(caller.toString())) {
            if (password.equals(credentials.get(caller.toString()))) {
                System.out.println("Successful authorization.");
                return proceed(caller);
            } else {
                System.out.println("Wrong password. Interrupting the call...");
            }
        } else {
            System.out.println("Customer does not exist");
        }

        return Optional.empty();
    }

}
