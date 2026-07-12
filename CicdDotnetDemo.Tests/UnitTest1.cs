namespace CicdDotnetDemo.Tests;

public class MathTests
{
    [Fact]
    public void Add_TwoPositiveNumbers_ReturnsCorrectSum()
    {
        // Arrange
        int a = 5;
        int b = 3;

        // Act
        int result = a + b;

        // Assert
        Assert.Equal(8, result);
    }

    [Fact]
    public void Add_NegativeNumber_ReturnsCorrectSum()
    {
        // Arrange
        int a = 10;
        int b = -3;

        // Act
        int result = a + b;

        // Assert
        Assert.Equal(7, result);
    }
}
