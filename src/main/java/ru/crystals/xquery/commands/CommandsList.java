package ru.crystals.xquery.commands;

import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;

public class CommandsList extends Command {
    private LinkedList<Command> origin;

    public CommandsList(Command... commands) {
        origin = new LinkedList<>(Arrays.asList(commands));
    }

    @Override
    public void update() throws Exception {
        Iterator<Command> iterator = origin.iterator();
        while (iterator.hasNext()) {
            iterator.next().update();
        }
    }

    @Override
    public void restore() {
        Iterator<Command> iterator = origin.descendingIterator();
        while (iterator.hasNext()) {
            iterator.next().restore();
        }
    }
}
