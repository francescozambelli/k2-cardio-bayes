# src/k2_algorithm.R
# Implementation of the K2 Algorithm for Bayesian Network Structure Learning

library(bnlearn)
library(dplyr)

#' K2 Algorithm with Log-Likelihood / BIC scoring (Numerical Stable Version)
#'
#' @param vars Character vector specifying the topological ordering of variables.
#' @param u Numeric vector or integer specifying the upper bound on the number of parents for each node.
#' @param D Data frame containing the training data.
#' @param type Scoring metric used by bnlearn (e.g. 'k2', 'bde', 'bic', 'bge').
#' @return A list where each element i contains the parents identified for node vars[i].
k2.new <- function(vars, u, D, type = "k2") {
  fin <- list(length = length(vars))
  
  for (i in 1:length(vars)) {
    curr.node <- vars[i]
    par <- c()
    netstr <- empty.graph(nodes = curr.node)
    p.old <- bnlearn::score(netstr, select(D, curr.node), type = type)
    okToProcede <- TRUE
    
    while (okToProcede && length(par) < u[i]) {
      # Candidates are preceding nodes in the ordering
      pred <- vars[0:(i - 1)]
      candidates <- pred[!(pred %in% par)]
      
      if (length(candidates) == 0) {
        break
      }
      
      p.news <- c()
      for (cand in candidates) {
        test.par <- c(par, cand)
        nodes <- c(test.par, curr.node)
        arcs <- matrix(c(test.par, rep(curr.node, length(test.par))), ncol = 2)
        colnames(arcs) <- c("from", "to")
        
        netstr <- empty.graph(nodes = nodes)
        arcs(netstr) <- arcs
        
        p.new <- bnlearn::score(netstr, select(D, all_of(nodes)), type = type)
        p.news <- c(p.news, p.new)
      }
      
      best.cand.idx <- which.max(p.news)
      p.best <- p.news[best.cand.idx]
      
      if (p.best > p.old) {
        p.old <- p.best
        par <- c(par, candidates[best.cand.idx])
      } else {
        okToProcede <- FALSE
      }
    }
    fin[[i]] <- par
  }
  return(fin)
}

#' Convert K2 Output to a bnlearn DAG
#'
#' @param var_list Character vector of variable names.
#' @param k2_res Output list from k2.new.
#' @param show Logical, whether to print the resulting DAG structure.
#' @return A bnlearn Directed Acyclic Graph (DAG) object.
k2_to_net <- function(var_list, k2_res, show = FALSE) {
  tus_dag <- empty.graph(nodes = var_list)
  
  for (i in 1:length(var_list)) {
    if (length(k2_res[[i]]) != 0) {
      for (j in k2_res[[i]]) {
        tus_dag <- set.arc(tus_dag, from = j, to = var_list[i])
      }
    }
  }
  
  if (show) {
    print(tus_dag)
  }
  return(tus_dag)
}

#' Score an ordering using K2 and bnlearn
#'
#' @param var_list Character vector of variable order.
#' @param D Data frame.
#' @param k2.score Scoring criterion for K2 search.
#' @param score.type Scoring criterion for total network evaluation.
#' @return A list containing the K2 parent result and the overall network score.
get_score <- function(var_list, D, k2.score = "k2", score.type = "k2") {
  upper_bounds <- rep(12, length(var_list))
  set.seed(123)
  k2_res <- k2.new(var_list, upper_bounds, D, type = k2.score)
  net <- k2_to_net(var_list, k2_res, show = FALSE)
  net_score <- bnlearn::score(net, D, type = score.type)
  return(list(k2_res, net_score))
}
