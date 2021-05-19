package com.proszkie.aspects;

public aspect Policeman {

    pointcut hackerCall(): within(com.proszkie.aspects.Hacker) && adviceexecution();

    void around(): hackerCall() {
        return;
    }
}
