

function getGCcontentInSlideWindowView(seq::BioSequence{DNAAlphabet{4}}, windowSize::Int, asProb::Bool, seqName::String)
	inputSeqLen = length(seq)
	@assert inputSeqLen >= windowSize
	restSeqLen = inputSeqLen % windowSize
	windowsNum = restSeqLen == 0 ? inputSeqLen ÷ windowSize : inputSeqLen ÷ windowSize + 1
	GCcontent = asProb ? zeros(Float32, windowsNum) : zeros(Int32, windowsNum)
	StartPos = zeros(Int32, windowsNum)
	StopPos = zeros(Int32, windowsNum)
	Chromosome = fill(seqName, windowsNum)
	for i = 0:(windowsNum-1)
		idx = i + 1
		start = i * windowSize + 1
		stop = restSeqLen == 0 ? (i + 1) * windowSize : 
		                         ( i == (windowsNum - 1) ? i * windowSize + restSeqLen : (i+1) * windowSize)
		StartPos[idx] = start
		StopPos[idx] = stop
		if i == (windowsNum - 1)
			@assert stop == inputSeqLen
		end
		subseq = seq[start:stop]
		actgComposition = BioSequences.Composition(subseq).counts
		numG = haskey(actgComposition, DNA_G) ? actgComposition[DNA_G] : 0
		numC = haskey(actgComposition, DNA_C) ? actgComposition[DNA_C] : 0
		numGC = numG + numC
		GCcontent[idx] = asProb ? round(numGC/windowSize, digits = 4) : numGC
	end
	output = DataFrame(Chrom = Chromosome, Start = StartPos, Stop = StopPos, GC = GCcontent)
	return output
end
