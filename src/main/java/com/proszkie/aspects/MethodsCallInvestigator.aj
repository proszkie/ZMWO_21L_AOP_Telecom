package com.proszkie.aspects;

import org.aspectj.lang.JoinPoint;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardOpenOption;
import java.util.Arrays;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public aspect MethodsCallInvestigator {
    private static final AtomicInteger id = new AtomicInteger(0);
    private static final AtomicInteger oldestId = new AtomicInteger(0);
    private static final File debugFile = new File("/tmp/aspects.log");

    static {
        createNewFile();
    }

    private static void createNewFile() {
        try {
            debugFile.delete();
            debugFile.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    pointcut methodExecution(Object caller): this(caller) && execution(* com.proszkie.telecom..*(..));

    Object around(Object caller): methodExecution(caller) {
        Timer timer = new Timer();
        timer.start();
        Object result = proceed(caller);
        timer.stop();
        appendToFile(caller, result, timer, thisJoinPoint);
        return result;
    }

    private void appendToFile(Object caller, Object result, Timer timer, JoinPoint joinPoint) {
        int currentId = id.incrementAndGet();
        int indentLevel = currentId - oldestId.get() - 1;
        appendToFile(indentLevel, caller, result, timer, joinPoint);
        oldestId.incrementAndGet();
    }

    private void appendToFile(int indentLevel, Object caller, Object result, Timer timer, JoinPoint joinPoint) {
        appendToFile(indentLevel, "Class of object calling the method: " + caller.getClass());
        appendToFile(indentLevel, "Called method signature: " + joinPoint.getSignature());
        appendToFile(indentLevel, "Called method args: " + Arrays.toString(joinPoint.getArgs()));
        appendToFile(indentLevel, "Called method result: " + result);
        appendToFile(indentLevel, "Processing time: " + timer.getTime() + " ms");
    }

    private void appendToFile(int indentLevel, String content) {
        String indent = IntStream.range(0, indentLevel).mapToObj(i -> "---").collect(Collectors.joining());
        try {
            Files.write(debugFile.toPath(), indent.concat(content.concat("\n")).getBytes(StandardCharsets.UTF_8), StandardOpenOption.APPEND);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
