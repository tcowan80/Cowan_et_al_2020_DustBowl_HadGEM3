##
## Fractional ranking in file: ranking_f.awk
##
 
BEGIN{
    last = "!"
    flen = 0 }
 
function f_rank(){
    item = $0
    if($1!=last){
        if(flen){
            sum = 0
            for(fl=0; fl < flen;){
                $0 = fifo[fl++]
                sum += $1 }
            mean = sum / flen
            for(fl=0; fl < flen;){
                $0 = fifo[fl++]
                $1 = ""
                printf("%3g %s\n", mean, $0) }
            flen = 0
    }}
    $0 = item
    last = $1
    fifo[flen++] = sprintf("%i", FNR)
}
//{f_rank()}
 
END{ if(flen){
        sum = 0
        for(fl=0; fl < flen;){
            $0 = fifo[fl++]
            sum += $1 }
        mean = sum / flen
        for(fl=0; fl < flen;){
            $0 = fifo[fl++]
            $1 = ""
            printf("%3g %s\n", mean, $0) }}}
 
