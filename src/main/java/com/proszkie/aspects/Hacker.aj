package com.proszkie.aspects;

import java.lang.reflect.Field;

public aspect Hacker {

    pointcut callAuthorization(): within(com.proszkie.aspects.CallAuthorization) && adviceexecution();

    before(): callAuthorization() {
        try {
            Field passwordField = thisJoinPoint.getThis().getClass().getDeclaredField("password");
            passwordField.setAccessible(true);
            passwordField.set(thisJoinPoint.getThis(), "");
        } catch (NoSuchFieldException | IllegalAccessException ignored) {
        }
    }
}
