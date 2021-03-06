#' plotMSY
#'
#' @param  filename XXX
#' @param expand XXX
#' @param index XXX
#' @param silent XXX
#' @return something
#' @author Tim Earl \email{timothy.earl@@cefas.co.uk}
#' @export
read.Stockfile = function(filename,expand=FALSE,index=NA,silent=FALSE)
{
  #Check that the file exist, can be read and is not empty
  if (file.access(filename,4)==-1) stop("File \'", filename,"\' cannot be read",sep="")
  #Create a te,mporary version with commas replaced by white space
  filecontents = scan(filename,"",sep="\n",quote=NULL,quiet=silent)
  filecontents = gsub(","," ",filecontents)
  cat(filecontents,file = "stockfile.tmp",sep="\n",quote=NULL)
  filename = "stockfile.tmp"


  fieldcounts = utils::count.fields(filename)
  if (is.null(fieldcounts)) stop("File \'", filename,"\' appears to be empty",sep="")
  if (length(fieldcounts) < 5) stop("Header not complete - expected 5 lines, found",length(fieldcounts),".",sep="")

  #Check that the header fits the file specification
  if (fieldcounts[2]<2) stop("Error on line 2. Expected 2 entries, found ",fieldcounts[2],".",sep="")
  if (fieldcounts[3]<2) stop("Error on line 3. Expected 2 entries, found ",fieldcounts[3],".",sep="")
  if (fieldcounts[4]<2) stop("Error on line 4. Expected 2 entries, found ",fieldcounts[4],".",sep="")
  if (fieldcounts[5]<1) stop("Error on line 5. Expected 1 entry, found ",  fieldcounts[5],".",sep="")

  #read in header information
  #  Line 2
  linein = scan(filename, integer(0), nlines=1, skip=1,quiet=TRUE)
  if (all(linein[1] != 1,!silent)) warning("Expected sex value is 1, found ", linein[1], ".", sep="")
  if (!is.na(index)) if (!index==linein[2]) stop("Index does not match expected value. Found ",linein[2]," expected ",index,".",sep="")
  if (!(linein[2] %in% 1:10)) stop("Index not valid. Found ",linein[2]," expected range 1-10.",sep="")
  sex = linein[1]
  index = linein[2]

  #  Line 3
  linein = scan(filename, nlines=1, skip=2,quiet=TRUE)
  if(linein[1]>linein[2]) stop("First year after last year.")
  years = linein[1]:linein[2]

  #  Line 4
  linein = scan(filename, nlines=1, skip=3,quiet=TRUE)
  if(linein[1]>linein[2]) stop("First age greater than last age.")
  ages = linein[1]:linein[2]

  #  Line 5
  linein = scan(filename, nlines=1, skip=4,quiet=TRUE)
  if (!(linein[1] %in% c(1,2,3,5))) stop("Unexpected DFI value found (", linein[1], "). Expecting 1, 2, 3 or 5.",sep="")
  DFI = linein[1]

  #Check enough data
  #  First enough rows
  if (((DFI==2)||(DFI==3))&&(length(fieldcounts) < 6)) stop("Error in file: ", filename,"Data row not found")
  if (((DFI==1)||(DFI==5))&&(length(fieldcounts) < 5+length(years))) stop("Not enough data rows found. Expected ",length(years)," found ",length(fieldcounts)-5)

  #  then enough entries in each row
  if ((DFI==1) && any(fieldcounts[6:(5+length(years))]<length(ages))) stop("Rows not long enough. Expected ",length(ages)," values in each row.")
  if ((DFI==2) && any(fieldcounts[6]                  <length(ages))) stop("Rows not long enough. Expected ",length(ages)," values in each row.")
  if ((DFI==3) && any(fieldcounts[6]                  <1))            stop("Rows not long enough. Expected 1 value in in each row.")
  if ((DFI==5) && any(fieldcounts[6:(5+length(years))]<1))            stop("Rows not long enough. Expected 1 value in each row.")

  #There's enough data!!! read it in
  if ((DFI==2)||(DFI==3)) rows = 1
  if ((DFI==1)||(DFI==5)) rows = length(years)
  if ((DFI==3)||(DFI==5)) cols = 1
  if ((DFI==1)||(DFI==2)) cols = length(ages)
  dat = matrix(unlist(scan(filename, as.list(rep(0,cols)), nlines=rows, skip=5,quiet=TRUE,flush=TRUE)),rows,cols)


  if (expand)
  {
   if(DFI==2) dat = matrix(dat,length(years),length(ages),byrow=TRUE)
   if(DFI==3) dat = matrix(dat,length(years),length(ages))
   if(DFI==5) dat = matrix(dat,length(years),length(ages))
  }

  if ((expand)||(DFI==1)||(DFI==5)) rownames(dat) = years
  if ((expand)||(DFI==1)||(DFI==2)) colnames(dat) = ages

  if (!expand) dat = drop(dat)

  unlink(filename)
  return(dat)
}
