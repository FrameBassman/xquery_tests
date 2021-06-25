package tech.romashov.xquery.commands;

import tech.romashov.xquery.ConsoleLogger;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class RunXqScripts extends ResourcesRelatedCommand {
    private ConsoleLogger log;
    private String directoryPath;
    private String fileExtension;

    public RunXqScripts(ConsoleLogger logger) {
        log = logger;
        directoryPath = "xq";
        fileExtension = ".xq";
    }

    @Override
    public void update() throws Exception {
        try (Stream<Path> walk = Files.walk(Paths.get(classLoader.getResource(directoryPath).getPath()))) {
            List<Path> paths = walk
                    .filter(file ->
                            file.toString().endsWith(fileExtension)
                                && Files.isRegularFile(file)
                    )
                    .sorted(Comparator.comparing(p -> {
                        String name = p.getFileName().toString();
                        return (name.contains("_U_") ? "0_" : "1_") + name;
                    }))
                    .collect(Collectors.toList());
            for (Path path : paths) {
                RunXqScript run = new RunXqScript(log, toRelatedPath(path));
                run.update();
            }
        }
    }

    @Override
    public void restore() {

    }

    protected String toRelatedPath(Path absolute) {
        return absolute.toString().replace(classLoader.getResource(directoryPath).getPath(), directoryPath);
    }
}
