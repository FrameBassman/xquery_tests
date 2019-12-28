package ru.crystals.xquery.commands;

public abstract class Command {
    public abstract void update() throws Exception;
    public abstract void restore();
}
