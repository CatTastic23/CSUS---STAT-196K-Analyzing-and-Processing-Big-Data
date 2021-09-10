# S - verifying assumptions in data
# Catherine nguyen#
# Stat196k 04/12/2021

# Shell commands
# aws s3 cp s3://stat196k-data-examples/processed990.zip ./ --no-sign-request
# unzip processed990.zip 
# seq 260783 | shuf -n 1    # 186869 is the index we will test. 

# Julia commands
import Serialization
using Statistics
using SparseArrays
terms = Serialization.deserialize("C:/Users/hlcn2/Desktop/Stats196k-notebooks/Hw4/processed990/terms.jldata")
termfreq = Serialization.deserialize("C:/Users/hlcn2/Desktop/Stats196k-notebooks/Hw4/processed990/termfreq.jldata")
irs990extract = Serialization.deserialize("C:/Users/hlcn2/Desktop/Stats196k-notebooks/Hw4/processed990/irs990extract.jldata")

# Part1: Question1
wordAppeared = 0 .< termfreq
# 260783×79653 SparseArrays.SparseMatrixCSC{Bool,Int64} with 5663744 stored entries:
totalTermCount = sum(wordAppeared, dims=1)
# 1×79653 Array{Int64,2}:
# 131  1  2  1  1  1  1  1  1  2  1  2  1  9  1  2  …  1  1  1  2  2  1  3  1  2  3  2  1  1  1 
# 1  1  1  10 
totalTermCountPerDoc = sum(wordAppeared, dims=2)
# 260783×1 Array{Int64,2}:
# 84
#  3
# 17
# 28
# 27
#  ⋮
# 32
# 32
# 36
#  5
transformedTermCount = totalTermCount[:]
# 79653-element Array{Int64,1}:
# 131
termsOneDoc = count(i -> i == 1, transformedTermCount)
# 48821
atleastFive = count(i -> i >= 5, transformedTermCount)
# 14235

sumFreq = sum(termfreq, dims=1)
# 1×79653 Array{Float64,2}:
sumFreq[:]
# 79653-element Array{Float64,1}:
sort(sumFreq[:], rev=true)
# 79653-element Array{Float64,1}:
# 16675.292361550302
# 13949.963961323843
# 12723.444920207457
#  9463.873055994802
#  5679.132445621643
#  5187.593097534592
#  4297.865650732847
#  3686.610885516793
#  3137.9862467054963
#  2791.9367827929336
#  2751.4890926385965
#  2321.214112629699
#  2190.558035865621
#  2131.2725408206616
#  2110.316062448749
#  1851.855938949833
#  1644.7742507471519
#  1471.4229732206898
#  1442.101196655262
#  1416.1477725395205
sortedSumFreq = sort(sumFreq[:], rev=true)
# 79653-element Array{Float64,1}:
top20WordFreq = sortedSumFreq[1:20]
# 20-element Array{Float64,1}:




terms[63167]
# "sacrameno"
termfreq[:, 63167]
# 260783-element SparseVector{Float64,Int64} with 1 stored entry:
#  [122401]  =  0.027027
irs990extract[122401]
# "THE MISSION OF THE SACRAMENTO REGION PERFORMING ARTS ALLIANCE IS TO PERFORM QUALITY SYMPHONIC MUSIC AND OPERA FOR THE GREATER SACRAMENO REGION THROUGH LIVE PROFESSIONAL PERFORMANCES AND COMMUNITY ENGAGEMENT INITIATIVES THAT INSPIRE, ENRICH, AND EXCITE OUR COMMUNITY."
irs990extract[122401]
# Dict{String,String} with 7 entries:
#  "name"       => "SACRAMENTO REGION PERFORMING ARTS"
#  "volunteers" => "12"
#  "revenue"    => "1720627"
#  "file"       => "201921349349304442_public.xml"
#  "mission"    => "THE MISSION OF THE SACRAMENTO REGION PERFORMING ARTS ALLIANCE IS TO …
#  "employees"  => "199"
#  "ein"        => "911841406"


# PART 2
x = irs990extract[1]
parse(Int, x["revenue"])

function parse_rev(x)
    r = x["revenue"]
    if ismissing(r)
        0
    else
        parse(Int, x["revenue"])
    end
end

revenues = map(parse_rev, irs990extract)

mostRev = sortperm(revenues, rev=true)

top10kidx = mostRev[1:10000]

# pick out the top 20 from the irs990 extract
top10k = irs990extract[top10kidx]

# pick out the top 20 from the termfreq
top20idx = mostRev[1:20]
 # 20-element Array{Int64,1}:
 # 93908
 # 62325
 # 197214
 # 115112
 # 134831
 # 123909
 # 198027
 # 226610
 # 175645
 # 147387
 # 196903
 # 237126
 # 46807
 # 98746
 # 151181
 # 233486
 # 126001
 # 185861
 # 25427
 # 174803
top20terms = termfreq[top20idx, 1:end]
  # 20×79653 SparseMatrixCSC{Float64,Int64} with 536 stored entries:
  # [16,   925]  =  0.0333333
  # [16,  2392]  =  0.0333333
  # [5 ,  3122]  =  0.0416667

top10kterms = termfreq[top10kidx, :]
 # 10000×79653 SparseMatrixCSC{Float64,Int64} with 279710 stored entries:
  #  [592 ,     1]  =  0.0232558
  #  [1308,     1]  =  0.03125
  #  [5151,     1]  =  0.0128205


# 2,3
sumtop10k = sum(top10kterms .> 0, dims=1)
# 1×79653 Array{Int64,2}:
# 8  0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0  0

sumtop10k = dropdims(sumtop10k, dims=1)

more_than_2 = sumtop10k .>= 2
# 79653 BitArray{2}:
# 1  0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0  0

top10ktermsMatrix = Matrix(top10kterms[:, more_than_2])
# 10000×4994 Array{Float64,2}:
# 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  …  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
# 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
# 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
# 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
# 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
# 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  …  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
# 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0     0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0