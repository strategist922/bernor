dmiss <- function(x, model) {

    if (! is.numeric(x)) stop("x not numeric")
    if (! inherits(model, "model")) stop("model not class \"model\"")

    imodel <- match(model$name, models()) - 1
    out <- .C("i1miss",
        model = as.integer(imodel),
        nhyper = integer(1),
        PACKAGE = "bernor")
    nhyper <- out$nhyper

    if (length(model$hyper) != nhyper) stop("hyper wrong length for model")
    out <- .C("i2miss",
        model = as.integer(imodel),
        hyper = as.integer(model$hyper),
        nparm = integer(1),
        nstate = integer(1),
        PACKAGE = "bernor")
    nparm <- out$nparm
    nstate <- out$nstate

    if (length(model$parm) != nparm)
        stop("parm wrong length for model and hyper")
    if (length(x) != nstate) stop("x wrong length for model and hyper")

    out <- .C("dmiss",
        x = as.double(x),
        model = as.integer(imodel),
        hyper = as.integer(model$hyper),
        parm = as.double(model$parm),
        result = double(1),
        PACKAGE = "bernor")
    return(out$result)
}
