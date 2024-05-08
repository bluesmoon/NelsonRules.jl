"""
Nelson rules are a method in process control of determining whether some measured variable is out of control
(unpredictable versus consistent). Rules for detecting "out-of-control" or non-random conditions were first
postulated by [Walter A. Shewhart](https://en.wikipedia.org/wiki/Walter_A._Shewhart) in the 1920s.
The Nelson rules were first published in the October 1984 issue of the Journal of Quality Technology in an
[article by Lloyd S Nelson](https://www.tandfonline.com/doi/abs/10.1080/00224065.1984.11978921).

The rules are applied to a control chart on which the magnitude of some variable is plotted against time.
The rules are based on the mean value and the standard deviation of the samples.

More information on the Nelson Rules are available at https://en.wikipedia.org/wiki/Nelson_rules

All rule methods in this module accept the same type of argument and return the same type of return value:

### Arguments
`series::Real[]`
: A timeseries vector to check for rule violation. Each entry is for a single unit of time.

### Returns
`Zip{Tuple{Intp[],Int[]}}`: An iterator of indices and sequence length of sequences that violate the particular Nelson Rule.

See the individual method documentation for rule description, examples and nuances.

Methods are named `ruleN` where `N` goes from 1-8. 
To make it easier to call multiple rules programmatically, methods may also be called via `rule(::Val{N}, series)` where `N` goes from 1-8.
"""
module NelsonRules

using Statistics

rule(::Val{1}, series) = rule1(series)
rule(::Val{2}, series) = rule2(series)
rule(::Val{3}, series) = rule3(series)
rule(::Val{4}, series) = rule4(series)
rule(::Val{5}, series) = rule5(series)
rule(::Val{6}, series) = rule6(series)
rule(::Val{7}, series) = rule7(series)
rule(::Val{8}, series) = rule8(series)

"""
Detects violation of nelson rule 1: One point is more than 3 standard deviations from the mean.

Problem Indicated: One or more samples are grossly out of control.

The sequence length in the return value will always be 1.

### Example
```julia
julia> NelsonRules.rule1([1, 2, 4, 5, 6, 7, -205, 9, -10, 12, 13, 200, 10, -5, 8, 3, -5, 5, 3, 9, -12, 17])
zip([7, 12], [1, 1])
```
"""
function rule1(series::AbstractVector{<:Real})
    mu = mean(series)
    sd = std(series)
    upper3Sd = mu + 3 * sd
    lower3Sd = mu - 3 * sd

    outsideRange = findall(.!(lower3Sd .<= series .<= upper3Sd))

    return zip(outsideRange, fill(1,length(outsideRange)))
end


"""
Detects violation of nelson rule 2: Nine (or more) points in a row are on the same side of the mean.

Problem Indicated: Some prolonged bias exists.

### Example
```julia
julia> NelsonRules.rule2([39, 398, 4, 76, 435, 188, 236, 283, 481, 271, 270, 274, 270, 272, 273, 273, 271, 271, 384, 194, 57, 232, 494, 468, 417, 104, 323, 469, 136, 214, 393, 267, 160, 385, 253, 155, 289, 455, 104, 289, 138, 184, 356, 186, 146, 268, 76, 258])
zip([8], [12])

julia> NelsonRules.rule2([26, 31, 46, 47, 81, 6, 88, 23, 73, 1, 66, 73, 6, 84, 70, 36, 80, 94, 63, 37, 62, 84, 53, 54, 80, 75, 26, 56, 48, 3, 6, 56, 21, 43, 87, 28, 47, 73, 63, 48, 68, 60, 63, 70, 60, 67, 61, 61, 66])
zip([41], [9])
```
"""
function rule2(series::AbstractVector{<:Real})
    # Need array of at least 9 items for this test
    if length(series) < 9
        return zip(Int[], Int[])
    end

    mu = mean(series)

    sideOfMean = sign.(series .- mu)

    sequencesOf9    = Int[]
    sequenceLengths = Int[]

    i = 1
    n = length(sideOfMean)
    while i <= n
        nextSignChange = something(findnext(!=(sideOfMean[i]), sideOfMean, i+1), n+1)
        if nextSignChange - i >= 9
            push!(sequencesOf9,    i)
            push!(sequenceLengths, nextSignChange-i)
            i = nextSignChange
        else
            i += 1
        end
    end

    return zip(sequencesOf9, sequenceLengths)
end


"""
Detects violation of nelson rule 3: Six (or more) points in a row are continually increasing (or decreasing).

Problem Indicated: A trend exists.

### Example
```julia
julia> NelsonRules.rule3([62, 79, 70, 81, 82, 83, 84, 87, 13, 83, 32, 5, 13, 36, 93, 74, 34, 20, 69, 96, 98, 101, 104, 107, 110])
zip([3, 18], [6, 8])
```
"""
function rule3(series::AbstractVector{<:Real})
    # Need array of at least 6 items for this test
    if length(series) < 6
        return zip(Int[], Int[])
    end

    deltaDirection = sign.(series[2:end] - series[1:end-1])

    sequencesOf6    = Int[]
    sequenceLengths = Int[]

    i = 1
    n = length(deltaDirection)

    while i <= n
        nextSignChange = something(findnext(!=(deltaDirection[i]), deltaDirection, i+1), n+1)
        if nextSignChange - i + 1 >= 6      # We have to add 1 because deltaDirection has 1 fewer data points than the original series
            push!(sequencesOf6,    i)
            push!(sequenceLengths, nextSignChange-i+1)
            i = nextSignChange
        else
            i += 1
        end
    end

    return zip(sequencesOf6, sequenceLengths)
end


"""
Detects violation of nelson rule 4: Fourteen (or more) points in a row alternate in direction, increasing then decreasing.

Problem Indicated: This much oscillation is beyond noise.

### Example
```julia
julia> NelsonRules.rule4([1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 3, 1, 2, 1, 2, 1, 2])
zip([1], [14])
```
"""
function rule4(series::AbstractVector{<:Real})
    if length(series) < 14
        return zip(Int[], Int[])
    end

    # We have 3 possibilities
    # x(i+1) == x(i) ->  0
    # x(i+1) >  x(i) -> +1
    # x(i+1) <  x(i) -> -1
    deltaDirection = sign.(series[2:end] - series[1:end-1])

    # We have 9 possibilities. The first 3 are when consecutive deltas are the same:
    # δ(i+1) == δ(i) ->  0
    # δ(i+1) == +1 && δ(i) ==  0 -> +1
    # δ(i+1) == +1 && δ(i) == -1 -> +2
    # δ(i+1) ==  0 && δ(i) == +1 -> -1
    # δ(i+1) ==  0 && δ(i) == -1 -> +1
    # δ(i+1) == -1 && δ(i) ==  0 -> -1
    # δ(i+1) == -1 && δ(i) == +1 -> -2
    # We only care about the case where value is ±2, so we take the absolute delta
    deltaSign = abs.(deltaDirection[2:end] - deltaDirection[1:end-1])

    altDirection = findall(deltaSign .== 2)

    # Now find the delta between indices
    altDirectionIdxDelta = altDirection[2:end] - altDirection[1:end-1]

    sequencesOf14   = Int[]
    sequenceLengths = Int[]

    # Finally find the longest sequence where the index deltas are 1 and if that is >= 14, we've found a rule breaker
    n = length(altDirection)
    i = 1
    while i <= n
        nextIdxChange = something(findnext(!=(1), altDirectionIdxDelta, i+1), n+1)
        if nextIdxChange - i + 3 >= 14     # We have to add 3 because altDirectionIdxDelta has 3 fewer data points than the original series
            push!(sequencesOf14,   i)
            push!(sequenceLengths, nextIdxChange-i+3)
        end
        i = nextIdxChange
    end

    return zip(sequencesOf14, sequenceLengths)
end


"""
Detects violation of nelson rule 5: Two (or three) out of three points in a row are more than 2 standard deviations from the mean in the same direction.

Problem Indicated: There is a medium tendency for samples to be mediumly out of control.

Note that the same sequence might show up for consecutive points as 2 out of 3 points can occur in two separate groups of 3 points.

### Example
```julia
julia> NelsonRules.rule5([1524, 1583, 2284, -882, 2184, -485, 57, -13, -3494, -3150, 1148, 2182, -953, 863, -31, -621, 947, -65, 323, -237])
zip([8, 9], [2, 2])
```
"""
function rule5(series::AbstractVector{<:Real})
    if length(series) < 3
        return zip(Int[], Int[])
    end

    mu = mean(series)
    sd = std(series)
    upper2Sd = mu + 2 * sd
    lower2Sd = mu - 2 * sd

    elementDirection = Vector{Int}(series .> upper2Sd) - Vector{Int}(series .< lower2Sd)

    sequenceOf3 = Int[abs(sum(elementDirection[i:i+2])) for i in 1:length(elementDirection) - 2]

    startOfSequenceOf2 = findall(sequenceOf3 .>= 2)

    return zip(startOfSequenceOf2, sequenceOf3[startOfSequenceOf2])
end



"""
Detects violation of nelson rule 6: Four (or five) out of five points in a row are more than 1 standard deviation from the mean in the same direction.

Problem Indicated: There is a strong tendency for samples to be slightly out of control.

### Example
```julia
julia> NelsonRules.rule6([816, 555, 712, 883, 397, 717, 165, 135, 261, 751, 1765, 1858, 1395, 1263, 1969, 253, 783, 631, 145, 924, -914, -701, -361, -590, 252, 848, 371, 546, 113, 984])
zip([10, 11, 12, 20, 21], [4, 5, 4, 4, 4])
```
"""
function rule6(series::AbstractVector{<:Real})
    if length(series) < 5
        return zip(Int[], Int[])
    end

    mu = mean(series)
    sd = std(series)
    upper1Sd = mu + sd
    lower1Sd = mu - sd

    elementDirection = Vector{Int}(series .> upper1Sd) - Vector{Int}(series .< lower1Sd)

    sequenceOf5 = Int[abs(sum(elementDirection[i:i+4])) for i in 1:length(elementDirection) - 4]

    startOfSequenceOf4 = findall(sequenceOf5 .>= 4)

    return zip(startOfSequenceOf4, sequenceOf5[startOfSequenceOf4])
end


"""
Detects violation of nelson rule 7: Fifteen points in a row are all within 1 standard deviation of the mean on either side of the mean.

Problem Indicated: With 1 standard deviation, greater variation would be expected.

The sequence length in the return value will always be 15.
Note that a sequence of more than 15 points will show as multiple consecutive sequences of 15 points each.

### Example
```julia
julia> NelsonRules.rule7([13, 81, 96, 40, 24, 66, 24, 34, 27, 72, 32, 73, 74, 22, 59, 39, 69, 62, 60, 2, 52, 51, 48, 25, 40, 60, 23, 109, -15, 57])
zip([4, 5], [15, 15])
```
"""
function rule7(series::AbstractVector{<:Real})
    if length(series) < 15
        return zip(Int[], Int[])
    end

    mu = mean(series)
    sd = std(series)
    upper1Sd = mu + sd
    lower1Sd = mu - sd

    within1Sd = lower1Sd .<= series .<= upper1Sd

    sequenceOf15 = [sum(within1Sd[i:i+14]) for i in 1:length(within1Sd) - 14]

    startOfSequenceOf15 = findall(sequenceOf15 .== 15)

    return zip(startOfSequenceOf15, sequenceOf15[startOfSequenceOf15])
end


"""
Detects violation of nelson rule 8: Eight points in a row exist, but none within 1 standard deviation of the mean, and the points are in both directions from the mean.

Problem Indicated: Jumping from above to below while missing the first standard deviation band is rarely random.

The sequence length in the return value will always be 8.
Note that a sequence of more than 8 points will show as multiple consecutive sequences of 8 points each.

### Example
```julia
julia> NelsonRules.rule8([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
zip([19, 20], [8, 8])
```
"""
function rule8(series::AbstractVector{<:Real})
    if length(series) < 8
        return zip(Int[], Int[])
    end

    mu = mean(series)
    sd = std(series)
    upper1Sd = mu + sd
    lower1Sd = mu - sd

    outside1Sd = .!(lower1Sd .<= series .<= upper1Sd)

    sequenceOf8 = [sum(outside1Sd[i:i+7]) for i in 1:length(outside1Sd) - 7]

    startOfSequenceOf8 = findall(sequenceOf8 .== 8)

    return zip(startOfSequenceOf8, sequenceOf8[startOfSequenceOf8])
end

end
