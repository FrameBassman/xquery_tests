package unit.tech.romashov.xquery;

import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import tech.romashov.xquery.commands.Command;
import tech.romashov.xquery.commands.CommandsList;

import static org.mockito.Mockito.verify;

public class CommandsListTests {
    private CommandsList commandsList;
    @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
    @Mock Command commandAlice;
    @Mock Command commandBob;

    @Test
    public void update_updateAllCommandsInList() throws Exception {
        // Arrange
        commandsList = new CommandsList(commandAlice, commandBob);

        // Act
        commandsList.update();

        // Assert
        verify(commandAlice).update();
        verify(commandBob).update();
    }
}
