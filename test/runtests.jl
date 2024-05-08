using Test, NelsonRules

@testset "Nelson Rules" begin
    @testset "Rule 1" begin
        series = [1, 2, 4, 5, 6, 7, -205, 9, -10, 12, 13, 200, 10, -5, 8, 3, -5, 5, 3, 9, -12, 17]
        @test collect(zip([7, 12], [1, 1])) == collect(NelsonRules.rule1(series))
        @test collect(zip([7, 12], [1, 1])) == collect(NelsonRules.rule(Val(1), series))
    end

    @testset "Rule 2" begin
        series1 = [39, 398, 4, 76, 435, 188, 236, 283, 481, 271, 270, 274, 270, 272, 273, 273, 271, 271, 384, 194, 57, 232, 494, 468, 417, 104, 323, 469, 136, 214, 393, 267, 160, 385, 253, 155, 289, 455, 104, 289, 138, 184, 356, 186, 146, 268, 76, 258]
        series2 = [26, 31, 46, 47, 81, 6, 88, 23, 73, 1, 66, 73, 6, 84, 70, 36, 80, 94, 63, 37, 62, 84, 53, 54, 80, 75, 26, 56, 48, 3, 6, 56, 21, 43, 87, 28, 47, 73, 63, 48, 68, 60, 63, 70, 60, 67, 61, 61, 66]

        @test collect(zip([8], [12])) == collect(NelsonRules.rule2(series1))
        @test collect(zip([41], [9])) == collect(NelsonRules.rule2(series2))

        @test collect(zip([8], [12])) == collect(NelsonRules.rule(Val(2), series1))
        @test collect(zip([41], [9])) == collect(NelsonRules.rule(Val(2), series2))

        # Empty result for < 9 items
        @test isempty(NelsonRules.rule2(series1[1:8]))
    end

    @testset "Rule 3" begin
        series = [62, 79, 70, 81, 82, 83, 84, 87, 13, 83, 32, 5, 13, 36, 93, 74, 34, 20, 69, 96, 98, 101, 104, 107, 110]
        @test collect(zip([3, 18], [6, 8])) == collect(NelsonRules.rule3(series))
        @test collect(zip([3, 18], [6, 8])) == collect(NelsonRules.rule(Val(3), series))

        # Empty result for < 6 items
        @test isempty(NelsonRules.rule3(series[1:5]))
    end

    @testset "Rule 4" begin
        series = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 3, 1, 2, 1, 2, 1, 2]
        @test collect(zip([1], [14])) == collect(NelsonRules.rule4(series))
        @test collect(zip([1], [14])) == collect(NelsonRules.rule(Val(4), series))

        # Empty result for < 14 items
        @test isempty(NelsonRules.rule4(series[1:13]))
    end

    @testset "Rule 5" begin
        series = [1524, 1583, 2284, -882, 2184, -485, 57, -13, -3494, -3150, 1148, 2182, -953, 863, -31, -621, 947, -65, 323, -237]
        @test collect(zip([8, 9], [2, 2])) == collect(NelsonRules.rule5(series))
        @test collect(zip([8, 9], [2, 2])) == collect(NelsonRules.rule(Val(5), series))

        # Empty result for < 3 items
        @test isempty(NelsonRules.rule5(series[1:2]))
    end

    @testset "Rule 6" begin
        series = [816, 555, 712, 883, 397, 717, 165, 135, 261, 751, 1765, 1858, 1395, 1263, 1969, 253, 783, 631, 145, 924, -914, -701, -361, -590, 252, 848, 371, 546, 113, 984]
        @test collect(zip([10, 11, 12, 20, 21], [4, 5, 4, 4, 4])) == collect(NelsonRules.rule6(series))
        @test collect(zip([10, 11, 12, 20, 21], [4, 5, 4, 4, 4])) == collect(NelsonRules.rule(Val(6), series))

        # Empty result for < 5 items
        @test isempty(NelsonRules.rule6(series[1:4]))
    end

    @testset "Rule 7" begin
        series = [13, 81, 96, 40, 24, 66, 24, 34, 27, 72, 32, 73, 74, 22, 59, 39, 69, 62, 60, 2, 52, 51, 48, 25, 40, 60, 23, 109, -15, 57]
        @test collect(zip([4, 5], [15, 15])) == collect(NelsonRules.rule7(series))
        @test collect(zip([4, 5], [15, 15])) == collect(NelsonRules.rule(Val(7), series))

        # Empty result for < 15 items
        @test isempty(NelsonRules.rule7(series[1:14]))
    end

    @testset "Rule 8" begin
        series = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        @test collect(zip([19, 20], [8, 8])) == collect(NelsonRules.rule8(series))
        @test collect(zip([19, 20], [8, 8])) == collect(NelsonRules.rule(Val(8), series))

        # Empty result for < 8 items
        @test isempty(NelsonRules.rule8(series[1:7]))
    end

end
