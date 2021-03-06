function [VATsubregionout] = VATsubregionstats(STNparcdir,outputfilename)
%VATsubregionstats Summary statistics of VAT within STN (or other) subregions

%Required arguments:
%% Input:
%%% STNparcdir: Directory containing NIFTI files corresponding to the STN zones (Accolla et al. 2014)
        %Current github repository directory (STNparcs) contains STN subregions
            %If used, please cite https://www.ncbi.nlm.nih.gov/pubmed/24777915
        %Ensure subregion NIFTIs are in the same image space as your LEAD DBS files
        %Note, Possible to include other subregion files
        
%% Output:
%%% outputfilename: Filename for extracted data table containing VATstats

%!!! make sure you are within the parent folder that contains the leadDBS output files, with each subfolder defining a subject
%% Assumed each LEADDBS VAT file for each subject is named 'rLEAD_DBS_VAT_LEFT.nii' - for the left hemisphere, for example.


%Dependencies: NIFTI tools https://au.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

%References: https://www.ncbi.nlm.nih.gov/pubmed/24777915


%setup working and subjects directories
workingdirectory = pwd;
files = dir(workingdirectory);
dirFlags=[files.isdir];
subFolders=files(dirFlags);
subFolders(1:2)=[];

%load in parcels of STN subregions for each hemisphere

[~,STNmotorRdata]=read([STNparcdir '/' 'LEAD_DBS_STN_motor_RIGHT.nii']);

[~,STNmotorLdata]=read([STNparcdir '/' 'LEAD_DBS_STN_motor_LEFT.nii']);

[~,STNassocLdata]=read([STNparcdir '/' 'LEAD_DBS_STN_associative_LEFT.nii']);

[~,STNassocRdata]=read([STNparcdir '/' 'LEAD_DBS_STN_associative_RIGHT.nii']);

[~,STNlimbicRdata]=read([STNparcdir '/' 'LEAD_DBS_STN_limbic_RIGHT.nii']);

[~,STNlimbicLdata]=read([STNparcdir '/' 'LEAD_DBS_STN_limbic_LEFT.nii']);


%now extract their centroids

[STNmotorRdataCOG,~]=extract_roi([STNparcdir '/' 'LEAD_DBS_STN_motor_RIGHT.nii']);

[STNmotorLdataCOG,~]=extract_roi([STNparcdir '/' 'LEAD_DBS_STN_motor_LEFT.nii']);

[STNassocLdataCOG,~]=extract_roi([STNparcdir '/' 'LEAD_DBS_STN_associative_LEFT.nii']);

[STNassocRdataCOG,~]=extract_roi([STNparcdir '/' 'LEAD_DBS_STN_associative_RIGHT.nii']);

[STNlimbicRdataCOG,~]=extract_roi([STNparcdir '/' 'LEAD_DBS_STN_limbic_RIGHT.nii']);

[STNlimbicLdataCOG,~]=extract_roi([STNparcdir '/' 'LEAD_DBS_STN_limbic_LEFT.nii']);


%finally, extract their corresponding voxels for each subregion
[STNmotorRvoxs]=find(STNmotorRdata==1);

[STNmotorLvoxs]=find(STNmotorLdata==1);

[STNassocRvoxs]=find(STNassocRdata==1);

[STNassocLvoxs]=find(STNassocLdata==1);

[STNlimbicRvoxs]=find(STNlimbicRdata==1);

[STNlimbicLvoxs]=find(STNlimbicLdata==1);


%load all the subjects VAT, as provided with LEAD DBS
for s = 1:length(subFolders)
    VATindivstats=[];
    
    currentSubj= subFolders(s,1).name;
    currentSubjDir = char([workingdirectory '/' currentSubj]);
    
    %parse VAT file strings
    %remove LEAD_DBS from ID strings
    VATsubjids{s,1} = currentSubj(10:end);
    
    SubjRVATfile=[currentSubjDir '/' 'rLEAD_DBS_VAT_RIGHT.nii'];
    [RVAThdr,RVATdata]=read(SubjRVATfile);
    
    SubjLVATfile=[currentSubjDir '/' 'rLEAD_DBS_VAT_LEFT.nii'];
    [LVAThdr,LVATdata]=read(SubjLVATfile);
    
    %calculate the extent of the stimulation field in each STN zone
    
    %first, calculate the "stimulated" voxels
    [r1]=find(RVATdata==1);
    [l1]=find(LVATdata==1);
    
    %Now determine the percentage overlap, first for Right motor
    
    cors=ismember(r1,STNmotorRvoxs);
    
    if isempty(cors)
        Rmotoroverlap=0;
        Rmotorperc=0;
    else
        Rmotoroverlap=find(cors==1);
        Rmotorperc=[length(Rmotoroverlap)./length(STNmotorRvoxs)]*100;
    end
    
    %Left Motor
    
    cors=ismember(l1,STNmotorLvoxs);
    
    if isempty(cors)
        Lmotoroverlap=0;
        Lmotorperc=0;
    else
        Lmotoroverlap=find(cors==1);
        Lmotorperc=[length(Lmotoroverlap)./length(STNmotorLvoxs)]*100;
    end
    
    %Right Assoc
    
    cors=ismember(r1,STNassocRvoxs);
    
    if isempty(cors)
        Rassocoverlap=0;
        Rassocperc=0;
    else
        Rassocoverlap=find(cors==1);
        Rassocperc=[length(Rassocoverlap)./length(STNassocRvoxs)]*100;
    end
    
    %Left Assoc
    
    cors=ismember(l1,STNassocLvoxs);
    
    if isempty(cors)
        Lassocoverlap=0;
        Lassocperc=0;
    else
        Lassocoverlap=find(cors==1);
        Lassocperc=[length(Lassocoverlap)./length(STNassocLvoxs)]*100;
    end
    
    %Right Limbic
    
    cors=ismember(r1,STNlimbicRvoxs);

    if isempty(cors)
    Rlimbicoverlap=0;
    Rlimbicperc=0;
    else
    Rlimbicoverlap=find(cors==1);
    Rlimbicperc=[length(Rlimbicoverlap)./length(STNlimbicRvoxs)]*100;
    end

    %Left Limbic

    cors=ismember(l1,STNlimbicLvoxs);

    if isempty(cors)
    Llimbicoverlap=0;
    Llimbicperc=0;
    else
    Llimbicoverlap=find(cors==1);
    Llimbicperc=[length(Llimbicoverlap)./length(STNlimbicLvoxs)]*100;
    end
 
%Euclidean Distances between electrode contact and subregion COG
%Calculate subject centroids first

[subjLSTNCOG,~]=extract_roi([SubjLVATfile]);
[subjRSTNCOG,~]=extract_roi([SubjRVATfile]);

%Now calculate the euclidean distance

DisSTNMotorR=sqrt(abs([(STNmotorRdataCOG(1,1)-subjRSTNCOG(1,1))*(STNmotorRdataCOG(1,1)-subjRSTNCOG(1,1))]+[(STNmotorRdataCOG(1,2)-subjRSTNCOG(1,2))*(STNmotorRdataCOG(1,2)-subjRSTNCOG(1,2))]+[(STNmotorRdataCOG(1,3)-subjRSTNCOG(1,3))*(STNmotorRdataCOG(1,3)-subjRSTNCOG(1,3))]));
DisSTNMotorL=sqrt(abs([(STNmotorLdataCOG(1,1)-subjLSTNCOG(1,1))*(STNmotorLdataCOG(1,1)-subjLSTNCOG(1,1))]+[(STNmotorLdataCOG(1,2)-subjLSTNCOG(1,2))*(STNmotorLdataCOG(1,2)-subjLSTNCOG(1,2))]+[(STNmotorLdataCOG(1,3)-subjLSTNCOG(1,3))*(STNmotorLdataCOG(1,3)-subjLSTNCOG(1,3))]));

DisSTNAssocR=sqrt(abs([(STNassocRdataCOG(1,1)-subjRSTNCOG(1,1))*(STNassocRdataCOG(1,1)-subjRSTNCOG(1,1))]+[(STNassocRdataCOG(1,2)-subjRSTNCOG(1,2))*(STNassocRdataCOG(1,2)-subjRSTNCOG(1,2))]+[(STNassocRdataCOG(1,3)-subjRSTNCOG(1,3))*(STNassocRdataCOG(1,3)-subjRSTNCOG(1,3))]));
DisSTNAssocL=sqrt(abs([(STNassocLdataCOG(1,1)-subjLSTNCOG(1,1))*(STNassocLdataCOG(1,1)-subjLSTNCOG(1,1))]+[(STNassocLdataCOG(1,2)-subjLSTNCOG(1,2))*(STNassocLdataCOG(1,2)-subjLSTNCOG(1,2))]+[(STNassocLdataCOG(1,3)-subjLSTNCOG(1,3))*(STNassocLdataCOG(1,3)-subjLSTNCOG(1,3))]));

DisSTNLimbicR=sqrt(abs([(STNlimbicRdataCOG(1,1)-subjRSTNCOG(1,1))*(STNlimbicRdataCOG(1,1)-subjRSTNCOG(1,1))]+[(STNlimbicRdataCOG(1,2)-subjRSTNCOG(1,2))*(STNlimbicRdataCOG(1,2)-subjRSTNCOG(1,2))]+[(STNlimbicRdataCOG(1,3)-subjRSTNCOG(1,3))*(STNlimbicRdataCOG(1,3)-subjRSTNCOG(1,3))]));
DisSTNLimbicL=sqrt(abs([(STNlimbicLdataCOG(1,1)-subjLSTNCOG(1,1))*(STNlimbicLdataCOG(1,1)-subjLSTNCOG(1,1))]+[(STNlimbicLdataCOG(1,2)-subjLSTNCOG(1,2))*(STNlimbicLdataCOG(1,2)-subjLSTNCOG(1,2))]+[(STNlimbicLdataCOG(1,3)-subjLSTNCOG(1,3))*(STNlimbicLdataCOG(1,3)-subjLSTNCOG(1,3))]));

%Output
%Combine individual VAT overlap stats into single matrix    
VATindivoverlapstats=cat(2, Rmotorperc, Lmotorperc, Rassocperc, Lassocperc,Rlimbicperc,Llimbicperc);

%Combine individual VAT distance stats into single matrix    

VATindivdiststats=cat(2, DisSTNMotorR, DisSTNMotorL, DisSTNAssocR, DisSTNAssocL, DisSTNLimbicR, DisSTNLimbicL);

%And then into full subject matrix
VATindivstats=cat(2,VATindivoverlapstats,VATindivdiststats);
VATsubregionout(s,:)=VATindivstats;

end

%Now write VAT stats to output matrix

fid = fopen([outputfile], 'wt');

fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'ID', 'Rmotorperc','Lmotorperc','Rassocperc','Lassocperc','Rlimbicperc','Llimbicperc','Rmotorcent','Lmotorcent','Rassoccent','Lassoccent','Rlimbiccent','Llimbiccent');
for s = 1:length(subFolders)
    fprintf(fid, '%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', VATsubjids{s,1},VATstatsall(s,1),VATstatsall(s,2),VATstatsall(s,3),VATstatsall(s,4),VATstatsall(s,5),VATstatsall(s,6),VATstatsall(s,7),VATstatsall(s,8),VATstatsall(s,9),VATstatsall(s,10),VATstatsall(s,11),VATstatsall(s,12));
end
fclose(fid)

%done!

function [COG, rois] = extract_roi(nii)
%% Extract centre of gravity for each integer within a NIFTI file

%% Input:
%%% nii: Filename of input nii file

%% Output
%%% COG: Centre of gravity for each integer i, denoted by a i x 3 structure
%%% rois: Structure corresponding to one fields; 
%%%% 1) coord: coordinates for each voxel within each integer

%% Dependencies:
%%% NIFTI tools: https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

nifti = load_untouch_nii(nii);

rois = {};
for i = 1:nifti.hdr.dime.dim(2)
    for j = 1:nifti.hdr.dime.dim(3)
        for k = 1:nifti.hdr.dime.dim(4)
            if nifti.img(i,j,k) > 0
                try
                    rois{nifti.img(i,j,k)}.coord = vertcat(rois{nifti.img(i,j,k)}.coord,[i-1,j-1,k-1]);
                catch
                    rois{nifti.img(i,j,k)}.coord = [i-1,j-1,k-1];
                end
            end
        end
    end
end

for i = 1:length(rois)
    rois{i}.coord(:,1) = (rois{i}.coord(:,1)*nifti.hdr.hist.srow_x(1)) + nifti.hdr.hist.srow_x(4);
    rois{i}.coord(:,2) = (rois{i}.coord(:,2)*nifti.hdr.hist.srow_y(2)) + nifti.hdr.hist.srow_y(4);
    rois{i}.coord(:,3) = (rois{i}.coord(:,3)*nifti.hdr.hist.srow_z(3)) + nifti.hdr.hist.srow_z(4);
    COG(i,:) = mean(rois{i}.coord);
end

end

end



