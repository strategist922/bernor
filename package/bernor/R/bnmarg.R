
bnmarg <- function(y, beta, sigma, nmiss, x, z, i, model, deriv = 0,
    want.weights = FALSE) {

    if (! is.numeric(y)) stop("y not numeric")
    if (! is.numeric(beta)) stop("beta not numeric")
    if (! is.numeric(sigma)) stop("sigma not numeric")
    if (! is.numeric(nmiss)) stop("nmiss not numeric")
    if (! is.numeric(x)) stop("x not numeric")
    if (! is.numeric(z)) stop("z not numeric")
    if (! is.numeric(i)) stop("i not numeric")
    if (! is.numeric(deriv)) stop("deriv not numeric")
    if (! is.logical(want.weights)) stop("want.weights not logical")
    if (! inherits(model, "model")) stop("model not class \"model\"")
    if (! is.matrix(x)) stop("x not matrix")
    if (! is.matrix(z)) stop("z not matrix")

    nran <- length(i)

    if (! all(is.element(y, 0:1))) stop("y not in 0, 1")
    ##### if (! all(sigma >= 0.0)) stop("sigma not nonnegative")
    if (! all(is.element(i, seq(along = sigma))))
        stop("! all(is.element(i, seq(along = sigma)))")
    if (length(deriv) != 1) stop("deriv not scalar")
    if (length(want.weights) != 1) stop("want.weights not scalar")
    if (! is.element(deriv, 0:2)) stop("deriv not in 0, 1, 2")

    if (length(nmiss) != 1) stop("nmiss not scalar")
    if (as.integer(nmiss) != nmiss) stop("nmiss not integer")
    if (nmiss <= 0) stop("nmiss not positive")

    if (nrow(x) != length(y)) stop("nrow(x) != length(y)")
    if (nrow(z) != length(y)) stop("nrow(z) != length(y)")
    if (ncol(x) != length(beta)) stop("ncol(x) != length(beta)")
    if (ncol(z) != nran) stop("ncol(z) != length(i)")
    storage.mode(x) <- "double"
    storage.mode(z) <- "double"

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
    if (nran != nstate) stop("i wrong length for model and hyper")

    ### note: the "other" nparm
    nparm <- length(beta) + length(sigma)

    if (want.weights) {
        wayout <- double(nmiss)
    } else {
        wayout <- double(0)
    }

    out <- .C("bnmarg",
        leny = length(y),
        lenfix = length(beta),
        lenran = as.integer(nran),
        lenvar = length(sigma),
        ncolx = ncol(x),
        ncolz = ncol(z),
        nmiss = as.integer(nmiss),
        y = as.integer(y),
        beta = as.double(beta),
        sigma = as.double(sigma),
        x = x,
        z = z,
        i = as.integer(i),
        value = double(1),
        grad = double(nparm),
        hess = matrix(as.double(0), nparm, nparm),
        deriv = as.integer(deriv),
        model = as.integer(imodel),
        hyper = as.integer(model$hyper),
        parm = as.double(model$parm),
        weigh = wayout,
        want.weights = want.weights,
        PACKAGE = "bernor")
    result <- list(value = out$value)
    if (deriv >= 1) result$gradient <- out$grad
    if (deriv == 2) result$hessian <- out$hess - outer(out$grad, out$grad)
    if (want.weights) result$weigh <- out$weigh
    return(result)
}
