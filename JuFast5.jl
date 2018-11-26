module JuFast5

using HDF5, Dates

export f5Reader, checkIntegrity, getAttr, getDataset,
       getASICId, getASICversion, getExpStartTime, 
	   getRunId, getVersion, getSequencingKit,
	   getFlowcellType, isLocalBasecalled,
	   getChannelNumber, getSamplingRate, getDigitisation,
	   getFlowcellID, getDeviceID, getDeviceType,
	   getHeatsinkTemp, getSampleID. getProtocolRunID,
	   getExpStartTime, getRunID, getVersion,
	   getProtocolsVersion, getASICId, getASICversion,
	   getExperimentDurationSet, getUserFilenameInput,
	   getExperimentType, getFilename

const requiredGroup = ["Raw", "UniqueGlobalKey", "PreviousReadInfo"]
const context_tags = "UniqueGlobalKey/context_tags"
const tracking_id = "UniqueGlobalKey/tracking_id"
const channel_id = "UniqueGlobalKey/channel_id"
const raw_reads = "Raw/Reads"

function checkIntegrity(hdf5Obj::HDF5File)
	for g in requiredGroup
		if !exists(hdf5Obj, g)
			error("Incomplete integrity! This Fast5 file lacks the group - ", g)
		end
	end
	nothing
end


function f5Reader(filename::AbstractString)
	f5 = h5open(filename, "r")
	checkIntegrity(f5)
	return f5
end


function getAttr(hdf5Obj::HDF5File, group::AbstractString, attr::AbstractString)
	if ! exists(hdf5Obj, group)
		error("Please check if given group is correct!")
	end

	if ! (attr in names(attrs(hdf5Obj[group])))
		error("Please check if given attribute name is correct!")
	end

	attrInfo = read(attrs(hdf5Obj[group]), attr)
	return attrInfo
end

# Get attributes from UniqueGlobalKey/channel_id

function getChannelNumber(hdf5Obj::HDF5File)
	attribute = "channel_number"
	channelnumber = getAttr(hdf5Obj, channel_id, attribute)
	return channelnumber
end

function getSamplingRate(hdf5Obj::HDF5File)
	attribute = "sampling_rate"
	samplingrate = getAttr(hdf5Obj, channel_id, attribute)
	return samplingrate
end

function getDigitisation(hdf5Obj::HDF5File)
	attribute = "digitisation"
	digitisation = getAttr(hdf5Obj, channel_id, attribute)
	return digitisation
end

# Get attributes from UniqueGlobalKey/tracking_id

function getFlowcellID(hdf5Obj::HDF5File)
	attribute = "flow_cell_id"
	flowcellid = getAttr(hdf5Obj, tracking_id, attribute)
end

function getDeviceID(hdf5Obj::HDF5File)
	attribute = "device_id"
	deviceid = getAttr(hdf5Obj, tracking_id, attribute)
	return deviceid
end

function getDeviceType(hdf5Obj::HDF5File)
	attribute = "device_type"
	devicetype = getAttr(hdf5Obj, tracking_id, attribute)
	return devicetype
end

function getHeatsinkTemp(hdf5Obj::HDF5File)
	attribute = "heatsink_temp"
	headsinktemp = getAttr(hdf5Obj, tracking_id, attribute)
	return heatsinktemp
end

function getProtocolRunID(hdf5Obj::HDF5File)
	attribute = "protocol_run_id"
	protocolrunid = getAttr(hdf5Obj, tracking_id, attribute)
	return protocolrunid
end

function getProtocolsVersion(hdf5Obj::HDF5File)
	attribute = "protocols_version"
	protocolversion = getAttr(hdf5Obj, tracking_id, attribute)
	return protocolversion
end

function getSampleId(hdf5Obj::HDF5File)
	attribute = "sample_id"
	sampleid = getAttr(hdf5Obj, tracking_id, attribute)
	return sampleid
end

function getASICId(hdf5Obj::HDF5File)
	attribute = "asic_id"
	asicid = getAttr(hdf5Obj, tracking_id, attribute)
	return asicid
end

function getASICversion(hdf5Obj::HDF5File)
	attribute = "asic_version"
	asicversion = getAttr(hdf5Obj, tracking_id, attribute)
	return asicversion
end

function getExpStartTime(hdf5Obj::HDF5File)
	attribute = "exp_start_time"
	exp_start_time = getAttr(hdf5Obj, tracking_id, attribute)
	start_time = replace(exp_start_time, r"Z$" => s"")
	timestamp::DateTime = Dates.DateTime(start_time)
	return timestamp
end

function getRunId(hdf5Obj::HDF5File)
	attribute = "run_id"
	runid = getAttr(hdf5Obj, tracking_id, attribute)
	return runid
end

function getVersion(hdf5Obj::HDF5File)
	attribute = "version"
	version = getAttr(hdf5Obj, tracking_id, attribute)
	return version
end


# Get attributes from UniqueGlobalKey/context_tags

function getSequencingKit(hdf5Obj::HDF5File)
	attribute = "sequencing_kit"
	seqKit = getAttr(hdf5Obj, context_tags, attribute)
	return seqKit
end

function getFlowcellType(hdf5Obj::HDF5File)
	attribute = "flowcell_type"
	flowcell = getAttr(hdf5Obj, context_tags, attribute)
	return flowcell
end

function isLocalBasecalled(hdf5Obj::HDF5File)
	attribute = "local_basecalling"
	islocalbasecalled = getAttr(hdf5Obj, context_tags, attribute)
	if islocalbasecalled == "1"
		return true
	else
		return false
	end
end

function getExperimentDurationSet(hdf5Obj::HDF5File)
	attribute = "experiment_duration_set"
	exp_duration = getAttr(htf5Obj, context_tags, attribute)
	return parse(Int16, exp_duration)
end

function getUserFilenameInput(hdf5Obj::HDF5File)
	attribute = "user_filename_input"
	userinput = getAttr(hdf5Obj, context_tags, attribute)
	return userinput
end


function getExperimentType(hdf5Obj::HDF5File)
	attribute = "experiment_type"
	exptype = getAttr(hdf5Obj, context_tags, attribute)
	return exptype
end


function getFileName(hdf5Obj::HDF5File)
	attribute = "filename"
	filename = getAttr(hdf5Obj, context_tags, attribute)
	return filename
end

# Get datasets from Raw/Reads/Read_x

function getDataset(hdf5Obj::HDF5File)
	dataset = get_datasets(hdf5Obj)
	if length(dataset) > 1
		println("\033[1;33m[Warning] There is more than one read in this fast5 file.\033[0m")
	end

	if length(get_datasets(hdf5Obj)) < 1
		error("No data exists in this fast5 file.")
	end

	return read(dataset[1])
end


end
